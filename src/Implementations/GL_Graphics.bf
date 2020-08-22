using static OpenGL43.GL;
using System;
using System.Collections;

namespace Pile.Implementations
{
	public class GL_Graphics : Graphics, IGraphicsOpenGL
	{
		public override String ApiName => "OpenGL Core";
		String deviceName;
		public override String DeviceName
		{
			get => deviceName;
		}
		public IGraphicsOpenGL.GLProfile Profile => IGraphicsOpenGL.GLProfile.Core;
		public override int32 MajorVersion => 4;
		public override int32 MinorVersion => 3;

		// Method needs to be static, so work around it like this, since there should only be one instance at a time anyway
		static void* GetProcAddress(StringView procName) => system.GetGLProcAddress(procName);
		static ISystemOpenGL system;

		private delegate void DeleteResource(uint32* id);
		readonly DeleteResource deleteTexture = new (id) => glDeleteTextures(1, id);

		// These were in context's ContextMeta class before and can be put back if we ever need multiple contexts
		bool context_forceScissorsUpdate;
		Rect context_viewport;
		// --

		List<uint32> texturesToDelete = new List<uint32>() ~ delete _;
		List<uint32> buffersToDelete = new List<uint32>() ~ delete _;

		public ~this()
		{
			system = null;

			delete deleteTexture;
			delete deviceName;
		}

		protected override Result<void, String> Initialize()
		{
			if (!(Core.System is ISystemOpenGL)) return .Err("System must be present and support openGL");
			system = Core.System as ISystemOpenGL;

			// Init & Config GL
			Init(=> GetProcAddress);
			glDepthMask(GL_TRUE);

			glEnable(GL_DEBUG_OUTPUT);
			glEnable(GL_DEBUG_OUTPUT_SYNCHRONOUS);

			glDebugMessageCallback(=> DebugCallback, null);
			glGetIntegerv(GL_MAX_TEXTURE_SIZE, &MaxTextureSize);
			deviceName = new String(glGetString(GL_RENDERER));
			OriginBottomLeft = true;

			return .Ok;
		}

		// Debug opion wirframe glPolygonMode(GL_FRONT_AND_BACK, GL_LINE) / default => glPolygonMode(GL_FRONT_AND_BACK, GL_FILL)

		protected override void Update()
		{
			DeleteResources(deleteTexture, texturesToDelete);
		}

		private void DeleteResources(DeleteResource deleter, List<uint32> list)
		{
			if (list.Count > 0)
			{
				for (int i = list.Count - 1; i >= 0; i--)
					deleter(&list[i]);
				list.Clear();
			}
		}

		protected override void AfterRender()
		{
			glFlush();
		}

		protected override void ClearInternal(RenderTarget target, Clear flags, Color color, float depth, int stencil, Rect viewport)
		{
			if (target is Window)
			{
				// Assume context is set right since there is only one

				glBindFramebuffer(GL_FRAMEBUFFER, 0);
				Clear(this, system.GetGLContext(), target, flags, color, depth, stencil, viewport);
			}
			// Else framebuffer
			
		}

		static void Clear(GL_Graphics graphics, ISystemOpenGL.Context context, RenderTarget target, Clear flags, Color color, float depth, int stencil, Rect _viewport)
		{
			Rect viewport = _viewport;

			// update the viewport
			{
			    viewport.Y = target.RenderSize.Y - viewport.Y - viewport.Height;

			    if (graphics.context_viewport != viewport)
			    {
			        glViewport(viewport.X, viewport.Y, viewport.Width, viewport.Height);
			        graphics.context_viewport = viewport;
			    }
			}

			// we disable the scissor for clearing
			graphics.context_forceScissorsUpdate = true;
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

		protected override void RenderInternal(ref RenderPass pass)
		{

			// Set size
			var size = Core.Window.RenderSize;
			glViewport(0, 0, size.X, size.Y);
		}

		protected override Texture.Platform CreateTexture(int32 width, int32 height, TextureFormat format)
		{
			return new [Friend]GL_Texture(this);
		}

		
		protected override Mesh.Platform CreateMesh()
		{
			return new [Friend]GL_Mesh(this);
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
			String.QuoteString(message, length, s);

			Console.WriteLine(s);
		}
	}
}
