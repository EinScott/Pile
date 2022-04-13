using Pile;
using System;

namespace Dimtoo
{
	class PixelGame<T> : Game<T> where T : Game
	{
		public enum ScalingMode
		{
			PixelPerfect,
			FillWindow,
			FitFrame
		}

		public readonly UPoint2 FrameSize;
		[Inline]
		public FrameBuffer Frame => frame;
		[Inline]
		public float FrameScale => renderScale;
		public ScalingMode Scaling = .PixelPerfect;

		FrameBuffer frame ~ delete _;
		float renderScale;
		Point2 frameOffset;

		public this(UPoint2 size)
		{
			FrameSize = size;
		}

		void Resized()
		{
			switch (Scaling)
			{
			case .PixelPerfect:
				// Update render scale to biggest pixel perfect match
				renderScale = Math.Max(Math.Min(
				    Math.Floor(System.Window.RenderSize.X / (float)frame.RenderSize.X),
				    Math.Floor(System.Window.RenderSize.Y / (float)frame.RenderSize.Y)), 1);

			case .FitFrame:
				// Update render scale to biggest full-fitting match
				renderScale = Math.Max(Math.Min(
					System.Window.RenderSize.X / (float)frame.RenderSize.X,
					System.Window.RenderSize.Y / (float)frame.RenderSize.Y), 1);

			case .FillWindow:
				// Update render scale to window-filling match
				renderScale = Math.Max(Math.Max(
					System.Window.RenderSize.X / (float)frame.RenderSize.X,
					System.Window.RenderSize.Y / (float)frame.RenderSize.Y), 1);

			}

			// Update frame offset to be centered
			frameOffset = Point2(
			    (int)((System.Window.RenderSize.X - renderScale * frame.RenderSize.X) / 2),
			    (int)((System.Window.RenderSize.Y - renderScale * frame.RenderSize.Y) / 2));
		}

		protected override void Startup()
		{
			frame = new FrameBuffer((.)FrameSize.X, (.)FrameSize.Y, .Color);

			//Core.Window.Resizable = true; (i guess you should still decide this yourself)
			System.Window.OnResized.Add(new => Resized);
			System.Window.MinSize = FrameSize;
			Resized();
		}

		protected override void Shutdown()
		{
			System.Window.OnResized.Remove(scope => Resized, true);
		}

		protected void RenderFrame(Batch2D batch)
		{
			batch.Image(frame, frameOffset, Vector2(renderScale, renderScale), .Zero, 0, .White);
		}

		public Point2 WindowToFrame(Point2 windowPosition)
		{
			var windowPosition;

		    // Take into account Frame to Window Origin offset
		    windowPosition -= frameOffset;

		    // Make position relative to frame buffer origin
		    let framePos = (Vector2)windowPosition / renderScale;

		    return framePos.ToRounded();
		}

		public Point2 FrameToWindow(Point2 framePosition)
		{
			var framePosition;

			// Make position relative to frame buffer origin
			var windowPos = (Vector2)framePosition * renderScale;

			// Take into account Frame to Window Origin offset
			windowPos += frameOffset;

			return windowPos.ToRounded();
		}
	}
}
