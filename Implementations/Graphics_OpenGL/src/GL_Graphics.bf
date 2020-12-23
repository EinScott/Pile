using OpenGL43;
using System;
using System.Collections;

using internal Pile;

namespace Pile
{
	extension Graphics : IGraphicsOpenGL
	{
		/*const uint32 MIN_VERSION_MAJOR = 3, MAX_VERSION_MAJOR = 4,
					VERSION_3_MINOR = 3, MIN_VERSION_MINOR = 0, MAX_VERSION_MINOR = 6;*/

		public override String ApiName => "OpenGL Core";
		String info = new String() ~ delete _;
		public override String Info
		{
			get => info;
		}
		public IGraphicsOpenGL.GLProfile Profile => IGraphicsOpenGL.GLProfile.Core;
		uint32 majorVersion = 3, minorVersion = 3;
		public override uint32 MajorVersion => majorVersion;
		public override uint32 MinorVersion => minorVersion;

		// Method needs to be static, so work around it like this, since there should only be one instance at a time anyway
		static void* GetProcAddress(StringView procName) => system.GetGLProcAddress(procName);
		static ISystemOpenGL system;

		private delegate void DeleteResource(ref uint32 id);
		readonly DeleteResource deleteTexture = new (id) => GL.glDeleteTextures(1, &id);
		readonly DeleteResource deleteBuffer = new (id) => GL.glDeleteBuffers(1, &id);
		readonly DeleteResource deleteProgram = new (id) => GL.glDeleteProgram(id);
		readonly DeleteResource deleteVertexArray = new (id) => GL.glDeleteVertexArrays(1, &id);
		readonly DeleteResource deleteFrameBuffer = new (id) => GL.glDeleteFramebuffers(1, &id);

		// These were in context's ContextMeta class before and can be put back if we ever need multiple contexts
		bool forceScissorUpdate;
		Rect viewport;
		RenderPass? lastRenderState;
		IRenderTarget lastRenderTarget;
		internal List<uint32> vertexArraysToDelete = new List<uint32>() ~ delete _;
		internal List<uint32> frameBuffersToDelete = new List<uint32>() ~ delete _;
		// --

		internal List<uint32> texturesToDelete = new List<uint32>() ~ delete _;
		internal List<uint32> buffersToDelete = new List<uint32>() ~ delete _;
		internal List<uint32> programsToDelete = new List<uint32>() ~ delete _;

		/*this
		{
			// Keep version within the supported spectrum
			this.majorVersion = Math.Min(MAX_VERSION_MAJOR, Math.Max(MIN_VERSION_MAJOR, majorVersion));
			this.minorVersion = majorVersion == 3 ? VERSION_3_MINOR : Math.Min(MAX_VERSION_MINOR, Math.Max(MIN_VERSION_MINOR, minorVersion));
		}*/

		this
		{
			OriginBottomLeft = true;
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

		protected internal override void Initialize()
		{
			if (!(Core.System is ISystemOpenGL)) Runtime.FatalError("System must support openGL");
			system = Core.System as ISystemOpenGL;

			// Config gl on system
			system.SetGLAttributes(24, 8, 1, 4);

			// Init & Config GL
			GL.Init(=> GetProcAddress);
			GL.glDepthMask(GL.GL_TRUE);

			GL.glEnable(GL.GL_DEBUG_OUTPUT);
			GL.glEnable(GL.GL_DEBUG_OUTPUT_SYNCHRONOUS);

			if (GL.glDebugMessageCallback != null) GL.glDebugMessageCallback(=> DebugCallback, null); // This may be not be avaiable depending on the version

			info.AppendF("device: {}, vendor: {}", StringView(GL.glGetString(GL.GL_RENDERER)), StringView(GL.glGetString(GL.GL_VENDOR)));
			GL.glGetIntegerv(GL.GL_MAX_TEXTURE_SIZE, &MaxTextureSize);
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
					GL.glPolygonMode(GL.GL_FRONT_AND_BACK, GL.GL_LINE);
				case .Disabled:
					GL.glPolygonMode(GL.GL_FRONT_AND_BACK, GL.GL_FILL);
				}
			}
		}

		protected internal override void Step()
		{
			RunDeleteLists();
		}

		void RunDeleteLists()
		{
			DeleteResources(deleteTexture, texturesToDelete);
			DeleteResources(deleteBuffer, buffersToDelete);
			DeleteResources(deleteProgram, programsToDelete);
			DeleteResources(deleteVertexArray, vertexArraysToDelete);
			DeleteResources(deleteFrameBuffer, frameBuffersToDelete);
		}

		private void DeleteResources(DeleteResource deleter, List<uint32> list)
		{
			if (list.Count > 0)
			{
				for (int i = list.Count - 1; i >= 0; i--)
					deleter(ref list[i]);
				list.Clear();
			}
		}

		protected internal override void AfterRender()
		{
			GL.glFlush();
		}

		protected internal override void ClearInternal(IRenderTarget target, Clear flags, Color color, float depth, int stencil, Rect viewport)
		{
			if (target is Window)
			{
				// Assume context is set right since there is only one -- basically we assume this everywhere

				GL.glBindFramebuffer(GL.GL_FRAMEBUFFER, 0);
				Clear(this, target, flags, color, depth, stencil, viewport);
			}
			else if (let fb = target as FrameBuffer)
			{
				// Bind frame buffer
				fb.Bind();
				Clear(this, target, flags, color, depth, stencil, viewport);
			}
		}

		static void Clear(Graphics graphics, IRenderTarget target, Clear flags, Color color, float depth, int stencil, Rect _viewport)
		{
			Rect viewport = _viewport;

			// update the viewport
			{
			    viewport.Y = (int)target.RenderSize.Y - viewport.Y - viewport.Height;

			    if (graphics.viewport != viewport)
			    {
			        GL.glViewport(viewport.X, viewport.Y, viewport.Width, viewport.Height);
			        graphics.viewport = viewport;
			    }
			}

			// we disable the scissor for clearing
			graphics.forceScissorUpdate = true;
			GL.glDisable(GL.GL_SCISSOR_TEST);

			// clear
			var mask = GL.GL_ZERO;

			if (flags.HasFlag(.Color))
			{
			    GL.glClearColor(color.Rf, color.Gf, color.Bf, color.Af);
			    mask |= GL.GL_COLOR_BUFFER_BIT;
			}

			if (flags.HasFlag(.Depth))
			{
			    GL.glClearDepth(depth);
			    mask |= GL.GL_DEPTH_BUFFER_BIT;
			}

			if (flags.HasFlag(.Stencil))
			{
			    GL.glClearStencil(stencil);
			    mask |= GL.GL_STENCIL_BUFFER_BIT;
			}

			GL.glClear(mask);
			GL.glBindFramebuffer(GL.GL_FRAMEBUFFER, 0);
		}

		protected internal override void RenderInternal(RenderPass pass)
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
				if (pass.target is Window) GL.glBindFramebuffer(GL.GL_FRAMEBUFFER, 0);
				else if (let fb = pass.target as FrameBuffer) fb.Bind();

				lastRenderTarget = pass.target;
			}

			// Use shader
			pass.material.Shader.Use(pass.material);

			// Bind mesh
			pass.mesh.Bind(pass.material);

			// Blend mode
			{
				GL.glEnable(GL.GL_BLEND);

				if (updateAll ||
				    lastPass.blendMode.colorOperation != pass.blendMode.colorOperation ||
				    lastPass.blendMode.alphaOperation != pass.blendMode.alphaOperation)
				{
				    uint colorOp = GetBlendFunc(pass.blendMode.colorOperation);
				    uint alphaOp = GetBlendFunc(pass.blendMode.alphaOperation);

				    GL.glBlendEquationSeparate(colorOp, alphaOp);
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

				    GL.glBlendFuncSeparate(colorSrc, colorDst, alphaSrc, alphaDst);
				}

				if (updateAll || lastPass.blendMode.mask != pass.blendMode.mask)
				{
				    GL.glColorMask(
				        (pass.blendMode.mask & .Red) != 0,
				        (pass.blendMode.mask & .Green) != 0,
				        (pass.blendMode.mask & .Blue) != 0,
				        (pass.blendMode.mask & .Alpha) != 0);
				}

				if (updateAll || lastPass.blendMode.color != pass.blendMode.color)
				{
				    GL.glBlendColor(
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
					GL.glDisable(GL.GL_DEPTH_TEST);
				else
				{
				    GL.glEnable(GL.GL_DEPTH_TEST);

				    switch (pass.depthFunction)
				    {
			        case .Always: GL.glDepthFunc(GL.GL_ALWAYS);
			        case .Equal: GL.glDepthFunc(GL.GL_EQUAL);
			        case .Greater: GL.glDepthFunc(GL.GL_GREATER);
			        case .GreaterOrEqual: GL.glDepthFunc(GL.GL_GEQUAL);
			        case .Less: GL.glDepthFunc(GL.GL_LESS);
			        case .LessOrEqual: GL.glDepthFunc(GL.GL_LEQUAL);
				    case .Never: GL.glDepthFunc(GL.GL_NEVER);
				    case .NotEqual: GL.glDepthFunc(GL.GL_NOTEQUAL);
					case .None:
				    }
				}
			}

			// Cull mode
			if (updateAll || lastPass.cullMode != pass.cullMode)
			{
				if (pass.cullMode == .None)
					GL.glDisable(GL.GL_CULL_FACE);
				else
				{
					GL.glEnable(GL.GL_CULL_FACE);

					switch (pass.cullMode)
					{
					case .Back: GL.glCullFace(GL.GL_BACK);
					case .Front: GL.glCullFace(GL.GL_FRONT);
					default: GL.glCullFace(GL.GL_FRONT_AND_BACK);
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
					GL.glViewport(viewport.X, viewport.Y, viewport.Width, viewport.Height);
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
				        GL.glDisable(GL.GL_SCISSOR_TEST);
				    }
				    else
				    {
				        GL.glEnable(GL.GL_SCISSOR_TEST);
				        GL.glScissor(scissor.X, scissor.Y, scissor.Width, scissor.Height);
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
					glIndexType = GL.GL_UNSIGNED_SHORT;
				case .UnsignedInt:
					glIndexType = GL.GL_UNSIGNED_INT;
				}

				if (pass.meshInstanceCount == 0)
				{
					GL.glDrawElements(GL.GL_TRIANGLES, (int)pass.meshIndexCount, glIndexType, (void*)(pass.mesh.IndexType.GetSize() * pass.meshIndexStart));
				}
				else
				{
					GL.glDrawElementsInstanced(GL.GL_TRIANGLES, (int)pass.meshIndexCount, glIndexType, (void*)(pass.mesh.IndexType.GetSize() * pass.meshIndexStart), (int)pass.meshInstanceCount);
				}

				GL.glBindVertexArray(0);
			}

			uint GetBlendFunc(BlendOperations operation)
			{
				switch (operation)
				{
				case .Add: 				return GL.GL_FUNC_ADD;
				case .Subtract: 		return GL.GL_FUNC_SUBTRACT;
				case .ReverseSubtract: 	return GL.GL_FUNC_REVERSE_SUBTRACT;
				case .Min: 				return GL.GL_MIN;
				case .Max: 				return GL.GL_MAX;
				}
			}

			uint GetBlendFactor(BlendFactors factor)
			{
				switch (factor)
				{
				case .Zero: 					return GL.GL_ZERO;
				case .One: 						return GL.GL_ONE;
				case .SrcColor: 				return GL.GL_SRC_COLOR;
				case .OneMinusSrcColor:			return GL.GL_ONE_MINUS_SRC_COLOR;
				case .DstColor: 				return GL.GL_DST_COLOR;
				case .OneMinusDstColor: 		return GL.GL_ONE_MINUS_DST_COLOR;
				case .SrcAlpha: 				return GL.GL_SRC_ALPHA;
				case .OneMinusSrcAlpha: 		return GL.GL_ONE_MINUS_SRC_ALPHA;
				case .DstAlpha: 				return GL.GL_DST_ALPHA;
				case .OneMinusDstAlpha: 		return GL.GL_ONE_MINUS_DST_ALPHA;
				case .ConstantColor: 			return GL.GL_CONSTANT_COLOR;
				case .OneMinusConstantColor: 	return GL.GL_ONE_MINUS_CONSTANT_COLOR;
				case .ConstantAlpha: 			return GL.GL_CONSTANT_ALPHA;
				case .OneMinusConstantAlpha: 	return GL.GL_ONE_MINUS_CONSTANT_ALPHA;
				case .SrcAlphaSaturate: 		return GL.GL_SRC_ALPHA_SATURATE;
				case .Src1Color: 				return GL.GL_SRC1_COLOR;
				case .OneMinusSrc1Color: 		return GL.GL_ONE_MINUS_SRC1_COLOR;
				case .Src1Alpha: 				return GL.GL_SRC1_ALPHA;
				case .OneMinusSrc1Alpha: 		return GL.GL_ONE_MINUS_SRC1_ALPHA;
				}
			}
		}

		static void DebugCallback(uint source, uint type, uint id, uint severity, int length, char8* message, void* userParam)
		{
			if (severity != GL.GL_DEBUG_SEVERITY_HIGH && severity != GL.GL_DEBUG_SEVERITY_MEDIUM && severity != GL.GL_DEBUG_SEVERITY_LOW) return;

			var s = scope String("OpenGL ");

			switch (type)
			{
			case GL.GL_DEBUG_TYPE_ERROR: s.Append("ERROR");
			case GL.GL_DEBUG_TYPE_DEPRECATED_BEHAVIOR: s.Append("DEPRECATED BEHAVIOR");
			case GL.GL_DEBUG_TYPE_MARKER: s.Append("MARKER");
			case GL.GL_DEBUG_TYPE_OTHER: s.Append("OTHER");
			case GL.GL_DEBUG_TYPE_PERFORMANCE: s.Append("PEROFRMANCE");
			case GL.GL_DEBUG_TYPE_POP_GROUP: s.Append("POP GROUP");
			case GL.GL_DEBUG_TYPE_PORTABILITY: s.Append("PORTABILITY");
			case GL.GL_DEBUG_TYPE_PUSH_GROUP: s.Append("PUSH GROUP");
			case GL.GL_DEBUG_TYPE_UNDEFINED_BEHAVIOR: s.Append("UNDEFINED BEHAVIOR");
			default: s.Append("UNKNOWN");
			}

			s.Append(", ");

			switch (severity)
			{
			case GL.GL_DEBUG_SEVERITY_HIGH: s.Append("HIGH");
			case GL.GL_DEBUG_SEVERITY_MEDIUM: s.Append("MEDIUM");
			case GL.GL_DEBUG_SEVERITY_LOW: s.Append("LOW");
			}

			s.Append(": ");

			// Add message
			s.Append(message, length);

			if (severity == GL.GL_DEBUG_SEVERITY_HIGH || type == GL.GL_DEBUG_TYPE_ERROR) Log.Error(s);
			else Log.Warning(s);
		}
	}
}
