using System;
using System.Collections;
using System.Diagnostics;
using Pile;

namespace Dimtoo
{
	class Sprite
	{
		Frame[] frames ~ delete _;
		Dictionary<String,Animation> animations ~ delete _;
		
		public readonly Point2 Origin;

		public readonly ReadOnlySpan<Frame> Frames;

		public this(Span<Frame> frameSpan, Span<(String name, Animation anim)> animSpan, Point2 origin = .Zero)
		{
			Debug.Assert(frameSpan.Length > 0, "Sprite has to have at least one frame");

			frames = new Frame[frameSpan.Length];
			if (frameSpan.Length > 0) frameSpan.CopyTo(frames);

			animations = new .();
			for (let tup in animSpan)
				animations.Add(tup.name, tup.anim);

			Frames = frames;
			Origin = origin;
		}

		[Inline]
		public bool HasAnimation(String name) => animations.ContainsKey(name);

		public Animation GetAnimation(String name)
		{
			if (animations.TryGetValue(name, let anim))
				return anim;

			Runtime.FatalError(scope $"Animation {name} couldn't be found");
		}

		[Inline]
		public void Draw(Batch2D batch, int frame, Vector2 position, Vector2 scale = .One, float rotation = 0, Color color = .White)
		{
			batch.Image(frames[frame].Texture, position, scale, Origin , rotation, color);
		}

		public static operator Subtexture(Sprite spr) => spr.frames[0].Texture;
	}
}
