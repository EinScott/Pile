using static OpenGL43.GL;
using System;
using System.Collections;

using internal Pile;

namespace Pile
{
	extension Graphics
	{
		public static override String ApiName => "OpenGL Core";
		static String info = new String() ~ delete _;
		public static override String Info
		{
			get => info;
		}

		function void DeleteResource(ref uint32 id);
		static void DeleteTexture(ref uint32 id) => glDeleteTextures(1, &id);
		static void DeleteBuffer(ref uint32 id) => glDeleteBuffers(1, &id);
		static void DeleteProgram(ref uint32 id) => glDeleteProgram(id);
		static void DeleteVertexArray(ref uint32 id) => glDeleteVertexArrays(1, &id);
		static void DeleteFrameBuffer(ref uint32 id) => glDeleteFramebuffers(1, &id);

		// These were in context's ContextMeta class before and can be put back if we ever need multiple contexts
		static bool forceScissorUpdate;
		static Rect viewport;
		static RenderPass? lastRenderState;
		static IRenderTarget lastRenderTarget;
		internal static List<uint32> vertexArraysToDelete = new List<uint32>() ~ delete _;
		internal static List<uint32> frameBuffersToDelete = new List<uint32>() ~ delete _;
		// --

		internal static List<uint32> texturesToDelete = new List<uint32>() ~ delete _;
		internal static List<uint32> buffersToDelete = new List<uint32>() ~ delete _;
		internal static List<uint32> programsToDelete = new List<uint32>() ~ delete _;

		static this()
		{
			MajorVersion = 3;
			MinorVersion = 3;
			Renderer = .OpenGLCore;

			OriginBottomLeft = true;
		}

		static ~this()
		{
			RunDeleteLists();
		}

		protected internal static override void Initialize()
		{
			if (System.RendererSupport case .OpenGLCore(let GetProcAddress, let SetGLAttributes))
			{
				// Config GL on System
				SetGLAttributes(24, 8, 1, 4);
	
				// Init & Config GL
				Init(=> GetProcAddress);
			}
			else Runtime.FatalError("System must support OpenGLCore");

			glDepthMask(GL_TRUE);

			glEnable(GL_DEBUG_OUTPUT);
			glEnable(GL_DEBUG_OUTPUT_SYNCHRONOUS);

			if (glDebugMessageCallback != null) glDebugMessageCallback(=> DebugCallback, null); // This may be not be available depending on the version

			info.AppendF("device: {}, vendor: {}", StringView(glGetString(GL_RENDERER)), StringView(glGetString(GL_VENDOR)));
			glGetIntegerv(GL_MAX_TEXTURE_SIZE, &MaxTextureSize);
		}

		static DebugDrawMode mode;
		public static override DebugDrawMode DebugDraw
		{
			get => mode;

			set
			{
				mode = value;

				switch (mode)
				{
				case .WireFrame:
					glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
				case .Disabled:
					glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
				}
			}
		}

		[Inline]
		protected internal static override void Step()
		{
			RunDeleteLists();
		}

		static void RunDeleteLists()
		{
			DeleteResources(=> DeleteTexture, texturesToDelete);
			DeleteResources(=> DeleteBuffer, buffersToDelete);
			DeleteResources(=> DeleteProgram, programsToDelete);
			DeleteResources(=> DeleteVertexArray, vertexArraysToDelete);
			DeleteResources(=> DeleteFrameBuffer, frameBuffersToDelete);

			void DeleteResources(DeleteResource deleter, List<uint32> list)
			{
				if (list.Count > 0)
				{
					for (int i = list.Count - 1; i >= 0; i--)
						deleter(ref list[[Unchecked]i]);
					list.Clear();
				}
			}
		}

		protected internal static override void AfterRender()
		{
			glFlush();
		}

		protected internal static override void ClearInternal(IRenderTarget target, Clear flags, Color color, float depth, int stencil, Rect viewport)
		{
			// Bind target
			if (lastRenderTarget != target)
			{
				if (target is Window) glBindFramebuffer(GL_FRAMEBUFFER, 0);
				else if (let fb = target as FrameBuffer) fb.Bind();

				lastRenderTarget = target;
			}

			// update the viewport
			{
				var viewport;
			    viewport.Y = (int)target.RenderSize.Y - viewport.Y - viewport.Height;

			    if (viewport != viewport)
			    {
			        glViewport(viewport.X, viewport.Y, viewport.Width, viewport.Height);
			        viewport = viewport;
			    }
			}

			// we disable the scissor for clearing
			forceScissorUpdate = true;
			glDisable(GL_SCISSOR_TEST);

			// clear
			var mask = GL_ZERO;

			if (flags.HasFlag(.Color))
			{
			    glClearColor(color.Rf, color.Gf, color.Bf, color.Af);
			    mask |= GL_COLOR_BUFFER_BIT;
			}

			if (flags.HasFlag(.Depth))
			{
			    glClearDepth(depth);
			    mask |= GL_DEPTH_BUFFER_BIT;
			}

			if (flags.HasFlag(.Stencil))
			{
			    glClearStencil(stencil);
			    mask |= GL_STENCIL_BUFFER_BIT;
			}

			glClear(mask);
		}

		protected internal static override void RenderInternal(RenderPass pass)
		{
			// Get last state
			RenderPass lastPass;
			var updateAll = false;
			if (lastRenderState == null)
			{
				updateAll = true;
				lastPass = pass;
			}
			else lastPass = lastRenderState.Value;
			 
			lastRenderState = pass;

			// Bind target
			if (updateAll || lastRenderTarget != pass.target)
			{
				if (pass.target is Window) glBindFramebuffer(GL_FRAMEBUFFER, 0);
				else if (let fb = pass.target as FrameBuffer) fb.Bind();

				lastRenderTarget = pass.target;
			}

			// Use shader
			pass.material.Shader.Use(pass.material);

			// Bind mesh
			pass.mesh.Bind(pass.material);

			// Blend mode
			{
				glEnable(GL_BLEND);

				if (updateAll ||
				    lastPass.blendMode.colorOperation != pass.blendMode.colorOperation ||
				    lastPass.blendMode.alphaOperation != pass.blendMode.alphaOperation)
				{
				    uint colorOp = GetBlendFunc(pass.blendMode.colorOperation);
				    uint alphaOp = GetBlendFunc(pass.blendMode.alphaOperation);

				    glBlendEquationSeparate(colorOp, alphaOp);
				}

				if (updateAll ||
				    lastPass.blendMode.colorSource != pass.blendMode.colorSource ||
				    lastPass.blendMode.colorDestination != pass.blendMode.colorDestination ||
				    lastPass.blendMode.alphaSource != pass.blendMode.alphaSource ||
				    lastPass.blendMode.alphaDestination != pass.blendMode.alphaDestination)
				{
				    uint colorSrc = GetBlendFactor(pass.blendMode.colorSource);
				    uint colorDst = GetBlendFactor(pass.blendMode.colorDestination);
				    uint alphaSrc = GetBlendFactor(pass.blendMode.alphaSource);
				    uint alphaDst = GetBlendFactor(pass.blendMode.alphaDestination);

				    glBlendFuncSeparate(colorSrc, colorDst, alphaSrc, alphaDst);
				}

				if (updateAll || lastPass.blendMode.mask != pass.blendMode.mask)
				{
				    glColorMask(
				        (pass.blendMode.mask & .Red) != 0,
				        (pass.blendMode.mask & .Green) != 0,
				        (pass.blendMode.mask & .Blue) != 0,
				        (pass.blendMode.mask & .Alpha) != 0);
				}

				if (updateAll || lastPass.blendMode.color != pass.blendMode.color)
				{
				    glBlendColor(
				        pass.blendMode.color.Rf,
				        pass.blendMode.color.Gf,
				        pass.blendMode.color.Bf,
				        pass.blendMode.color.Af);
				}
			}

			// Depth function
			if (updateAll || lastPass.depthFunction != pass.depthFunction)
			{
				if (pass.depthFunction == .None)
					glDisable(GL_DEPTH_TEST);
				else
				{
				    glEnable(GL_DEPTH_TEST);

				    switch (pass.depthFunction)
				    {
			        case .Always: glDepthFunc(GL_ALWAYS);
			        case .Equal: glDepthFunc(GL_EQUAL);
			        case .Greater: glDepthFunc(GL_GREATER);
			        case .GreaterOrEqual: glDepthFunc(GL_GEQUAL);
			        case .Less: glDepthFunc(GL_LESS);
			        case .LessOrEqual: glDepthFunc(GL_LEQUAL);
				    case .Never: glDepthFunc(GL_NEVER);
				    case .NotEqual: glDepthFunc(GL_NOTEQUAL);
					case .None:
				    }
				}
			}

			// Cull mode
			if (updateAll || lastPass.cullMode != pass.cullMode)
			{
				if (pass.cullMode == .None)
					glDisable(GL_CULL_FACE);
				else
				{
					glEnable(GL_CULL_FACE);

					switch (pass.cullMode)
					{
					case .Back: glCullFace(GL_BACK);
					case .Front: glCullFace(GL_FRONT);
					default: glCullFace(GL_FRONT_AND_BACK);
					}
				}
			}

			let size = (Point2)pass.target.RenderSize;

			// Viewport
			var viewport = pass.viewport ?? Rect(0, 0, size.X, size.Y);
			{
				viewport.Top = size.Y - viewport.Y - viewport.Height;

				if (updateAll || Graphics.viewport != viewport)
				{
					glViewport(viewport.X, viewport.Y, viewport.Width, viewport.Height);
					Graphics.viewport = viewport;
				}
			}

			// Scissor
			{
				var scissor = pass.scissor ?? Rect(0, 0, size.X, size.Y);
				scissor.Y = size.Y - scissor.Y - scissor.Height;
				scissor.Width = Math.Max(0, scissor.Width);
				scissor.Height = Math.Max(0, scissor.Height);

				if (updateAll || lastPass.scissor != scissor || forceScissorUpdate)
				{
				    if (pass.scissor == null)
				    {
				        glDisable(GL_SCISSOR_TEST);
				    }
				    else
				    {
				        glEnable(GL_SCISSOR_TEST);
				        glScissor(scissor.X, scissor.Y, scissor.Width, scissor.Height);
				    }

				    forceScissorUpdate = false;
				    lastPass.scissor = scissor;
				}
			}

			// Draw mesh
			{
				uint glIndexType;
				switch (pass.mesh.IndexType)
				{
				case .UnsignedByte:
					glIndexType = GL_UNSIGNED_BYTE;
				case .UnsignedShort:
					glIndexType = GL_UNSIGNED_SHORT;
				case .UnsignedInt:
					glIndexType = GL_UNSIGNED_INT;
				}

				if (pass.meshInstanceCount == 0)
				{
					glDrawElements(GL_TRIANGLES, (int)pass.meshIndexCount, glIndexType, (void*)(pass.mesh.IndexType.GetSize() * pass.meshIndexStart));
				}
				else
				{
					glDrawElementsInstanced(GL_TRIANGLES, (int)pass.meshIndexCount, glIndexType, (void*)(pass.mesh.IndexType.GetSize() * pass.meshIndexStart), (int)pass.meshInstanceCount);
				}

				glBindVertexArray(0);
			}

			uint GetBlendFunc(BlendOperations operation)
			{
				switch (operation)
				{
				case .Add: 				return GL_FUNC_ADD;
				case .Subtract: 		return GL_FUNC_SUBTRACT;
				case .ReverseSubtract: 	return GL_FUNC_REVERSE_SUBTRACT;
				case .Min: 				return GL_MIN;
				case .Max: 				return GL_MAX;
				}
			}

			uint GetBlendFactor(BlendFactors factor)
			{
				switch (factor)
				{
				case .Zero: 					return GL_ZERO;
				case .One: 						return GL_ONE;
				case .SrcColor: 				return GL_SRC_COLOR;
				case .OneMinusSrcColor:			return GL_ONE_MINUS_SRC_COLOR;
				case .DstColor: 				return GL_DST_COLOR;
				case .OneMinusDstColor: 		return GL_ONE_MINUS_DST_COLOR;
				case .SrcAlpha: 				return GL_SRC_ALPHA;
				case .OneMinusSrcAlpha: 		return GL_ONE_MINUS_SRC_ALPHA;
				case .DstAlpha: 				return GL_DST_ALPHA;
				case .OneMinusDstAlpha: 		return GL_ONE_MINUS_DST_ALPHA;
				case .ConstantColor: 			return GL_CONSTANT_COLOR;
				case .OneMinusConstantColor: 	return GL_ONE_MINUS_CONSTANT_COLOR;
				case .ConstantAlpha: 			return GL_CONSTANT_ALPHA;
				case .OneMinusConstantAlpha: 	return GL_ONE_MINUS_CONSTANT_ALPHA;
				case .SrcAlphaSaturate: 		return GL_SRC_ALPHA_SATURATE;
				case .Src1Color: 				return GL_SRC1_COLOR;
				case .OneMinusSrc1Color: 		return GL_ONE_MINUS_SRC1_COLOR;
				case .Src1Alpha: 				return GL_SRC1_ALPHA;
				case .OneMinusSrc1Alpha: 		return GL_ONE_MINUS_SRC1_ALPHA;
				}
			}
		}

		static void DebugCallback(uint source, uint type, uint id, uint severity, int length, char8* message, void* userParam)
		{
			if (severity != GL_DEBUG_SEVERITY_HIGH && severity != GL_DEBUG_SEVERITY_MEDIUM && severity != GL_DEBUG_SEVERITY_LOW) return;

			var s = scope String("OpenGL ");

			switch (type)
			{
			case GL_DEBUG_TYPE_ERROR: s.Append("ERROR");
			case GL_DEBUG_TYPE_DEPRECATED_BEHAVIOR: s.Append("DEPRECATED BEHAVIOR");
			case GL_DEBUG_TYPE_MARKER: s.Append("MARKER");
			case GL_DEBUG_TYPE_OTHER: s.Append("OTHER");
			case GL_DEBUG_TYPE_PERFORMANCE: s.Append("PEROFRMANCE");
			case GL_DEBUG_TYPE_POP_GROUP: s.Append("POP GROUP");
			case GL_DEBUG_TYPE_PORTABILITY: s.Append("PORTABILITY");
			case GL_DEBUG_TYPE_PUSH_GROUP: s.Append("PUSH GROUP");
			case GL_DEBUG_TYPE_UNDEFINED_BEHAVIOR: s.Append("UNDEFINED BEHAVIOR");
			default: s.Append("UNKNOWN");
			}

			s.Append(", ");

			switch (severity)
			{
			case GL_DEBUG_SEVERITY_HIGH: s.Append("HIGH");
			case GL_DEBUG_SEVERITY_MEDIUM: s.Append("MEDIUM");
			case GL_DEBUG_SEVERITY_LOW: s.Append("LOW");
			}

			s.Append(": ");

			// Add message
			s.Append(message, length);

			if (severity == GL_DEBUG_SEVERITY_HIGH || type == GL_DEBUG_TYPE_ERROR) Log.Error(s);
			else Log.Warn(s);
		}
	}
}
