using System;
using System.Reflection;
using System.Diagnostics;
using System.Collections;

using internal Pile;

namespace Pile
{
	[AttributeUsage(.Method)]
	struct PerfTrackAttribute : Attribute, IComptimeMethodApply
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
			Compiler.EmitMethodEntry(methodInfo, Performance.MakePerfTrackScopeCode(sectionName));
#endif
		}
	}

	static class Performance
	{
		// We need double buffering here because render functions should also be able to fill these
		// Thus the stats will just be delayed by one frame
		static Dictionary<String, TimeSpan> sectionDurationsFill ~ DeleteNotNull!(_);
		static Dictionary<String, TimeSpan> sectionDurationsRead ~ DeleteNotNull!(_);

		static Stopwatch trackWatch ~ DeleteNotNull!(_);

		const String trackSection = "Pile.Performance (PerfTrack overhead)";
		static TimeSpan trackOverhead = .Zero;

		/// Whether or not to track function performance.
		/// PerfTrack is always disabled if DEBUG is not defined
		public static bool Track = false;

		public static int Scale = 3;
		public static int PerfTrackDisplayCount = 10;
		public static int PerfTrackCollectInterval = 30; // in steps/frames/loops
		static int collectCounter = PerfTrackCollectInterval - 1;

		[DebugOnly]
		internal static void Initialize()
		{
			sectionDurationsFill = new .();
			sectionDurationsRead = new .();

			trackWatch = new .(true);
		}

		[DebugOnly]
		internal static void Step()
		{
			if (!Track) return;
			let __pt = scope System.Diagnostics.Stopwatch(true);

			// Only collect on interval so you can actually read the numbers, especially in the lower digits
			if (collectCounter >= PerfTrackCollectInterval)
			{
				Swap!(sectionDurationsFill, sectionDurationsRead);
				sectionDurationsFill.Clear();

				for (let pair in ref sectionDurationsRead)
				{
					// Average over collection interval
					*pair.valueRef = TimeSpan((*pair.valueRef).Ticks / PerfTrackCollectInterval);
				}

				collectCounter = 0;

				// Sneak our internal time into the read dictionary we just switched
				trackOverhead += __pt.Elapsed;
				sectionDurationsRead.Add(trackSection, TimeSpan(trackOverhead.Ticks / PerfTrackCollectInterval));
				trackOverhead = .Zero;
			}
			else
			{
				collectCounter++;
				trackOverhead += __pt.Elapsed;
			}
		}

		static int64 StartSection() => trackWatch.[Friend]GetElapsedDateTimeTicks();

		[DebugOnly]
		static void EndSection(String sectionName, TimeSpan time)
		{
			if (!Track) return;
			let __pt = scope System.Diagnostics.Stopwatch(true); // Track this manually to not... infinite loop

			if (sectionDurationsFill.GetValue(sectionName) case .Ok(let val))
			{
				sectionDurationsFill[sectionName] = val + time; // Sum up
			}
			else sectionDurationsFill.Add(sectionName, time);

			trackOverhead += __pt.Elapsed;
		}

		[Comptime]
		/// Can be used together with Compiler.Mixin
		public static String MakePerfTrackScopeCode(String scopeName)
		{
#if DEBUG
			// Crappy 64 bit hash
			uint sNum = 0;
			for (let i < scopeName.Length)
			{
				let val = (uint8)scopeName[i];

				if (val % 5 == 0 && val % 2 == 0)
					sNum ^= val;
				else if (val % 3 == 0)
					sNum *= val;
				else sNum += val;
			}

			return new $"""
				let __pt_s{sNum} = scope System.Diagnostics.Stopwatch(true);
				defer
				{{
					Pile.Performance.[System.FriendAttribute]EndSection("{scopeName}", __pt_s{sNum}.Elapsed);
				}}
				""";
#else
			return "";
#endif
		}

		[PerfTrack]
		public static void Render(Batch2D batch, SpriteFont font)
		{
			Debug.Assert(Scale > 0);

			// Current raw delta drawn as bar
			{
				const Point2 targetOffset = .(17, 1);
				const Point2 barOffset = .(1, 2);
				const int64 defaultTargetTicks = (int64)((double)TimeSpan.TicksPerSecond / Time.[Friend]DEFAULT_TARGET_FPS);

				int64 targetTicks;
				if (Time.TargetFPS != 0)
					targetTicks = Time.targetTicks;
				else // Assume mark to be at default target frame rate (60fps)
					targetTicks = defaultTargetTicks;

				batch.Rect(.(targetOffset * Scale, Point2(1, Scale * 3)), .Red);

				// If minFPS is enforced and we're not on fixed time step (it's the same as target)
				if (Time.MinFPS != 0 && Time.maxTicks != Time.targetTicks)
				{
					// draw bar where delta time cap is!
					batch.Rect(
						.(Point2((int)(targetOffset.X * ((double)Time.maxTicks / targetTicks)),
							targetOffset.Y) * Scale,
							Point2(1, Scale * 3)),
						.LightGray);
				}

				batch.Rect(
					.(barOffset * Scale,
						Point2((int)((targetOffset.X * Scale) * ((double)Time.loopTicks / targetTicks)),
						Scale)),
					.White);
			}

			let scale = Vector2(((float)Scale / font.Size) * 5);

			String perfText = scope .();

			// Fps, delta & freeze
			{
				int64 tFPS = 0;
				if (Time.loopTicks > 0)
					tFPS = TimeSpan.TicksPerSecond / Time.loopTicks;

				perfText.AppendF("FPS: {}, tFPS: {:0000}, RawDelta: {:0.0000}s, Delta: {:0.0000}s, Freeze: {}\n", Time.FPS, tFPS, Time.RawDelta, Time.Delta, Time.freeze > 0);
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
							if (ranking.Count == PerfTrackDisplayCount) // Remove if we would push beyond what we need
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
					perfText.AppendF("{:0.000}ms {}\n", (float)pair.value.Ticks / TimeSpan.[Friend]TicksPerMillisecond, pair.key);
				}
			}
#endif

			batch.Text(font, perfText, .(Scale, 4 * Scale), scale, .Zero, 0, .White);
		}
	}
}
