using System;
using System.Reflection;
using System.Diagnostics;
using System.Collections;

using internal Pile;

namespace Pile
{
	[AttributeUsage(.Method)]
	public struct PerfTrackAttribute : Attribute, IComptimeMethodApply
	{
		String sectionNameOverride;
		bool appendOverride;

		public this(String sectionNameOverride = String.Empty, bool appendOverride = false)
		{
#if DEBUG
			this.sectionNameOverride = sectionNameOverride;
			this.appendOverride = appendOverride;
#else
			this.sectionNameOverride = String.Empty;
			this.appendOverride = false;
#endif
		}

		[Comptime]
		public void ApplyToMethod(ComptimeMethodInfo methodInfo)
		{
#if DEBUG
			// Make name
			let sectionName = appendOverride
				? scope String()
				: scope String(sectionNameOverride);

			if (sectionName.IsEmpty)
			{
				methodInfo.ToString(sectionName);
				sectionName.RemoveFromEnd(Math.Abs(sectionName.IndexOf('(') - sectionName.Length));

				if (appendOverride)
					sectionName..Append(' ')..Append(sectionNameOverride);
			}

			// Put tracking on method
			Compiler.EmitMethodEntry(methodInfo, scope $"""
				let __pt = scope System.Diagnostics.Stopwatch(true);
				#unwarn // "This defer will immediately execute [...]", which it will not
				defer
				{{
					Performance.[Friend]TrackSection("{sectionName}", __pt.Elapsed);
				}}
				""");
#endif
		}
	}

	public static class Performance
	{
		// We need double buffering here because render functions should also be able to fill these
		// Thus the stats will just be delayed by one frame
		static Dictionary<String, TimeSpan> sectionDurationsFill ~ DeleteNotNull!(_);
		static Dictionary<String, TimeSpan> sectionDurationsRead ~ DeleteNotNull!(_);

		const String trackSection = "Pile.Performance (PerfTrack overhead)";

		/// Whether or not to track function performance.
		/// PerfTrack is always disabled if DEBUG is not defined
		public static bool Track = true;

		public static int Scale = 3;
		public static int PerfTrackDisplayCount = 10;

#if !DEBUG
		[SkipCall]
#endif
		internal static void Initialize()
		{
			sectionDurationsFill = new .()..Add(trackSection, default);
			sectionDurationsRead = new .()..Add(trackSection, default);
		}

#if !DEBUG
		[SkipCall]
#endif
		[PerfTrack(trackSection)]
		internal static void Step()
		{
			if (!Track) return;

			Swap!(sectionDurationsFill, sectionDurationsRead);

			// Clean
			/*for (var pair in ref sectionDurationsFill)
				*pair.valueRef = .Zero;*/

			sectionDurationsFill.Clear();
		}

#if !DEBUG
		[SkipCall]
#endif
		private static void TrackSection(String sectionName, TimeSpan time)
		{
			if (!Track) return;
			let __pt = scope System.Diagnostics.Stopwatch(true); // Track this manually to not... infinite loop

			if (sectionDurationsFill.GetValue(sectionName) case .Ok(let val))
			{
				sectionDurationsFill[sectionName] = val + time; // Sum up
			}
			else sectionDurationsFill.Add(sectionName, time);

			// Performance.Step is called before this. That function itself has [PerfTrack] with trackSection on it
			// so when we get here, an entry for trackSection has at least been create just above
			sectionDurationsFill[trackSection] += __pt.Elapsed;
		}

		[PerfTrack]
		public static void Render(Batch2D batch, SpriteFont font)
		{
			Debug.Assert(Scale > 0);

			// Current raw delta drawn as bar
			{
				const Point2 targetOffset = .(17, 1);
				const Point2 barOffset = .(1, 2);
				const int64 defaultTargetTicks = (int64)((double)Time.[Friend]TICKS_PER_SECOND / Time.[Friend]DEFAULT_TARGET_FPS);

				int64 targetTicks;
				if (Time.TargetFPS != 0)
					targetTicks = Time.targetTicks;
				else // Assume mark to be at default target frame rate (60fps)
					targetTicks = defaultTargetTicks;

				batch.Rect(.(targetOffset * Scale, Point2(Scale, Scale * 3)), .Red);

				// If minFPS is enforced and we're not on fixed time step (it's the same as target)
				if (Time.MinFPS != 0 && Time.maxTicks != Time.targetTicks)
				{
					// draw bar where delta time cap is!
					batch.Rect(
						.(Point2((int)(targetOffset.X * ((double)Time.maxTicks / targetTicks)),
							targetOffset.Y) * Scale,
							Point2(Scale, Scale * 3)),
						.LightGray);
				}

				batch.Rect(
					.(barOffset * Scale,
						Point2((int)((targetOffset.X * Scale) * ((double)Time.loopTicks / targetTicks)),
						Scale)),
					.White);
			}

			let scale = Vector2(((float)Scale / font.Size) * 5);
			var yOffset = 4 * Scale;

			// Fps, delta & freeze
			{
				batch.Text(font, scope $"FPS: {Time.FPS}, RawDelta: {Time.RawDelta:0.0000}s, Delta: {Time.Delta:0.0000}s, Freeze: {Time.freeze > 0}", .(Scale, yOffset), scale, .Zero, 0, .White);
				yOffset += (.)(font.LineHeight * scale.Y) + Scale;
			}

#if DEBUG
			if (sectionDurationsRead.Count > 0)
			{
				List<(String key, TimeSpan value)> ranking = scope .();

				for (let pair in sectionDurationsRead) // Rank sections
				{
					bool inserted = false;
					for (int i < ranking.Count)
					{
						let ranked = ref ranking[i];
						if (ranked.value < pair.value) // The pair should be here in the table
						{
							if (ranking.Count == PerfTrackDisplayCount) // Remove if we would push beyong what we need
								ranking.PopBack();

							ranking.Insert(i, pair);
							inserted = true;
							break;
						}
					}

					if (!inserted && ranking.Count < PerfTrackDisplayCount)
						ranking.Add(pair);
				}

				for (let pair in ranking) // Draw sections
				{
					batch.Text(font, scope $"{((float)pair.value.Ticks / TimeSpan.[Friend]TicksPerMillisecond):0.000}ms {pair.key}", .(Scale, yOffset), scale, .Zero, 0, .White);
					yOffset += (.)(font.LineHeight * scale.Y) + Scale;
				}
			}
#endif
		}
	}
}
