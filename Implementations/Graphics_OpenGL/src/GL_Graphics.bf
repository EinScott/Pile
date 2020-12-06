using static OpenGL43.GL;
using System;
using System.Collections;

using internal Pile;

namespace Pile.Implementations
{
	public class GL_Graphics : Graphics, IGraphicsOpenGL
	{
		const uint32 MIN_VERSION_MAJOR = 3, MAX_VERSION_MAJOR = 4,
					VERSION_3_MINOR = 3, MIN_VERSION_MINOR = 0, MAX_VERSION_MINOR = 6;

		public override String ApiName => "OpenGL Core";
		String info = new String() ~ delete _;
		public override String Info
		{
			get => info;
		}
		public IGraphicsOpenGL.GLProfile Profile => IGraphicsOpenGL.GLProfile.Core;
		uint32 majorVersion, minorVersion;
		public override uint32 MajorVersion => majorVersion;
		public override uint32 MinorVersion => minorVersion;

		// Method needs to be static, so work around it like this, since there should only be one instance at a time anyway
		static void* GetProcAddress(StringView procName) => system.GetGLProcAddress(procName);
		static ISystemOpenGL system;

		private delegate void DeleteResource(ref uint32 id);
		readonly DeleteResource deleteTexture = new (id) => glDeleteTextures(1, &id);
		readonly DeleteResource deleteBuffer = new (id) => glDeleteBuffers(1, &id);
		readonly DeleteResource deleteProgram = new (id) => glDeleteProgram(id);
		readonly DeleteResource deleteVertexArray = new (id) => glDeleteVertexArrays(1, &id);
		readonly DeleteResource deleteFrameBuffer = new (id) => glDeleteFramebuffers(1, &id);

		// These were in context's ContextMeta class before and can be put back if we ever need multiple contexts
		bool forceScissorUpdate;
		Rect viewport;
		RenderPass? lastRenderState;
		RenderTarget lastRenderTarget;
		internal List<uint32> vertexArraysToDelete = new List<uint32>() ~ delete _;
		internal List<uint32> frameBuffersToDelete = new List<uint32>() ~ delete _;
		// --

		internal List<uint32> texturesToDelete = new List<uint32>() ~ delete _;
		internal List<uint32> buffersToDelete = new List<uint32>() ~ delete _;
		internal List<uint32> programsToDelete = new List<uint32>() ~ delete _;

		public this(uint32 majorVersion = 3, uint32 minorVersion = 3)
		{
			// Keep version within the supported spectrum
			this.majorVersion = Math.Min(MAX_VERSION_MAJOR, Math.Max(MIN_VERSION_MAJOR, majorVersion));
			this.minorVersion = majorVersion == 3 ? VERSION_3_MINOR : Math.Min(MAX_VERSION_MINOR, Math.Max(MIN_VERSION_MINOR, minorVersion));
		}

		internal ~this()
		{
			system = null;

			RunDeleteLists();

			delete deleteTexture;
			delete deleteBuffer;
			delete deleteProgram;
			delete deleteVertexArray;
			delete deleteFrameBuffer;
		}

		internal override Result<void> Initialize()
		{
			if (!(Core.System is ISystemOpenGL)) LogErrorReturn!("System must support openGL");
			system = Core.System as ISystemOpenGL;

			// Config gl on system
			system.SetGLAttributes(24, 8, 1, 4);

			// Init & Config GL
			Init(=> GetProcAddress);
			glDepthMask(GL_TRUE);

			glEnable(GL_DEBUG_OUTPUT);
			glEnable(GL_DEBUG_OUTPUT_SYNCHRONOUS);

			if (glDebugMessageCallback != null) glDebugMessageCallback(=> DebugCallback, null); // This may be not be avaiable depending on the version

			info.AppendF("device: {}, vendor: {}", StringView(glGetString(GL_RENDERER)), StringView(glGetString(GL_VENDOR)));
			glGetIntegerv(GL_MAX_TEXTURE_SIZE, &MaxTextureSize);

			OriginBottomLeft = true;

			return .Ok;
		}

		DebugDrawMode mode;
		public override DebugDrawMode DebugDraw
		{
			get => mode;

			set
			{
				mode = value;

				switch(mode)
				{
				case .WireFrame:
					glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
				case .Disabled:
					glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
				}
			}
		}

		internal override void Step()
		{
			RunDeleteLists();
		}

		[DisableChecks]
		void RunDeleteLists()
		{
			DeleteResources(deleteTexture, texturesToDelete);
			DeleteResources(deleteBuffer, buffersToDelete);
			DeleteResources(deleteProgram, programsToDelete);
			DeleteResources(deleteVertexArray, vertexArraysToDelete);
			DeleteResources(deleteFrameBuffer, frameBuffersToDelete);
		}

		[DisableChecks]
		[DisableObjectAccessChecks]
		private void DeleteResources(DeleteResource deleter, List<uint32> list)
		{
			if (list.Count > 0)
			{
				for (int i = list.Count - 1; i >= 0; i--)
					deleter(ref list[i]);
				list.Clear();
			}
		}

		internal override void AfterRender()
		{
			glFlush();
		}

		[DisableChecks]
		[DisableObjectAccessChecks]
		protected override void ClearInternal(RenderTarget target, Clear flags, Color color, float depth, int stencil, Rect viewport)
		{
			if (target is Window)
			{
				// Assume context is set right since there is only one -- basically we assume this everywhere

				glBindFramebuffer(GL_FRAMEBUFFER, 0);
				Clear(this, target, flags, color, depth, stencil, viewport);
			}
			else if (let fb = target as FrameBuffer)
			{
				// Bind frame buffer
				(fb.platform as GL_FrameBuffer).Bind();
				Clear(this, target, flags, color, depth, stencil, viewport);
			}
		}

		static void Clear(GL_Graphics graphics, RenderTarget target, Clear flags, Color color, float depth, int stencil, Rect _viewport)
		{
			Rect viewport = _viewport;

			// update the viewport
			{
			    viewport.Y = (int)target.RenderSize.Y - viewport.Y - viewport.Height;

			    if (graphics.viewport != viewport)
			    {
			        glViewport(viewport.X, viewport.Y, viewport.Width, viewport.Height);
			        graphics.viewport = viewport;
			    }
			}

			// we disable the scissor for clearing
			graphics.forceScissorUpdate = true;
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
			glBindFramebuffer(GL_FRAMEBUFFER, 0);
		}

		[DisableChecks]
		[DisableObjectAccessChecks]
		protected override void RenderInternal(ref RenderPass pass)
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
				else if (let fb = pass.target as FrameBuffer) (fb.platform as GL_FrameBuffer).Bind();

				lastRenderTarget = pass.target;
			}

			// Use shader
			(pass.material.Shader.platform as GL_Shader).Use(pass.material);

			// Bind mesh
			(pass.mesh.platform as GL_Mesh).Bind(pass.material);

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

				if (updateAll || this.viewport != viewport)
				{
					glViewport(viewport.X, viewport.Y, viewport.Width, viewport.Height);
					this.viewport = viewport;
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

		internal override Texture.Platform CreateTexture(uint32 width, uint32 height, TextureFormat format) => new GL_Texture(this, width, height, format);

		internal override FrameBuffer.Platform CreateFrameBuffer(uint32 width, uint32 height, TextureFormat[] attachments) => new GL_FrameBuffer(this, width, height, attachments);
		
		internal override Mesh.Platform CreateMesh() => new GL_Mesh(this);

		internal override Shader.Platform CreateShader(ShaderData source) => new GL_Shader(this, source);

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
			else Log.Warning(s);
		}
	}
}
