using System;
using System.Reflection;
using System.Diagnostics;
using System.Collections;

using internal Pile;

#if DEBUG || PILE_FORCE_DEBUG_TOOLS
#define USE_PERF
#endif

namespace Pile
{
	static
	{
		[Comptime,Obsolete("Use PerfTrack()", false)]
		public static mixin PerfTrack(String scopeName) => PerfTrack(scopeName);

		[Comptime]
		public static void PerfTrack(String scopeName)
		{
#if USE_PERF
			let sNum = (uint)scopeName.GetHashCode();

			Compiler.MixinRoot(scope $"""
				let __pt_s{sNum} = scope System.Diagnostics.Stopwatch(true);
				defer
				{{
					Pile.Perf.[System.FriendAttribute]EndSection("{scopeName}", __pt_s{sNum}.Elapsed);
				}}
				""");
#endif
		}
	}

	[AttributeUsage(.Method)]
	struct PerfTrackAttribute : Attribute, IComptimeMethodApply
	{
		String sectionNameOverride;
		bool appendOverride;

		public this(String sectionNameOverride = String.Empty, bool appendOverride = false)
		{
			this.sectionNameOverride = sectionNameOverride;
			this.appendOverride = appendOverride;
		}

		[Comptime]
		public void ApplyToMethod(ComptimeMethodInfo methodInfo)
		{
#if USE_PERF
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

			let sNum = (uint)sectionName.GetHashCode();

			// Put tracking on method
			Compiler.EmitMethodEntry(methodInfo, scope $"""
				let __pt_s{sNum} = scope System.Diagnostics.Stopwatch(true);
				defer
				{{
					Pile.Perf.[System.FriendAttribute]EndSection("{sectionName}", __pt_s{sNum}.Elapsed);
				}}
				""");
#endif
		}
	}

	static class Perf
	{
		// We need double buffering here because render functions should also be able to fill these
		// Thus the stats will just be delayed by one collection cycle
		static Dictionary<String, TimeSpan> sectionDurationsFill ~ DeleteNotNull!(_);
		static Dictionary<String, TimeSpan> sectionDurationsRead ~ DeleteNotNull!(_);

		const String trackSection = "Pile.Perf (PerfTrack overhead)";
		static TimeSpan trackOverhead = .Zero;

		/// Whether or not to track function performance.
		/// PerfTrack is always disabled if DEBUG is not defined
		public static bool Track = false;

		public static int TrackCollectInterval = 30; // in steps/frames/loops
		static int collectCounter;

#if !USE_PERF
		[SkipCall]
#endif
		internal static void Initialize()
		{
			sectionDurationsFill = new .();
			sectionDurationsRead = new .();
		}

#if !USE_PERF
		[SkipCall]
#endif
		internal static void Step()
		{
			if (!Track) return;
			let __pt = scope System.Diagnostics.Stopwatch(true);

			// Only collect on interval so you can actually read the numbers, especially in the lower digits
			if (collectCounter >= TrackCollectInterval)
			{
				Swap!(sectionDurationsFill, sectionDurationsRead);
				sectionDurationsFill.Clear();

				for (let pair in ref sectionDurationsRead)
				{
					// Average over collection interval
					*pair.valueRef = TimeSpan((*pair.valueRef).Ticks / TrackCollectInterval);
				}

				collectCounter = 0;

				// Sneak our internal time into the read dictionary we just switched
				trackOverhead += __pt.Elapsed;
				sectionDurationsRead.Add(trackSection, TimeSpan(trackOverhead.Ticks / TrackCollectInterval));
				trackOverhead = .Zero;
			}
			else
			{
				collectCounter++;
				trackOverhead += __pt.Elapsed;
			}
		}

#if !USE_PERF
		[SkipCall]
#endif
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

#unwarn // yes... we don't need [Friend] here... calm down
		[PerfTrack]
		public static void Render(Batch2D batch, SpriteFont font, int scale = 3, int perfTrackDisplayCount = 10)
		{
			Debug.Assert(scale > 0);

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

				batch.Rect(.(targetOffset * scale, Point2(1, scale * 3)), .Red);

				// If minFPS is enforced and we're not on fixed time step (it's the same as target)
				if (Time.MinFPS != 0 && Time.maxTicks != Time.targetTicks)
				{
					// draw bar where delta time cap is!
					batch.Rect(
						.(Point2((int)(targetOffset.X * ((double)Time.maxTicks / targetTicks)),
							targetOffset.Y) * scale,
							Point2(1, scale * 3)),
						.LightGray);
				}

				batch.Rect(
					.(barOffset * scale,
						Point2((int)((targetOffset.X * scale) * ((double)Time.loopTicks / targetTicks)),
						scale)),
					.White);
			}

			if (font != null)
			{
				let textScale = Vector2(((float)scale / font.Size) * 5);
	
				String perfText = scope .();
	
				// Fps, delta & freeze
				STATS:
				{
					int64 tFPS = 0;
					if (Time.loopTicks > 0)
						tFPS = TimeSpan.TicksPerSecond / Time.loopTicks;

					String gfxMem = String.Empty;
					if (Graphics.debugInfo.totalGPUMemMB != 0)
					{
						gfxMem = scope:STATS .()..AppendF("GPU Memory: {}/{}MB, ", Graphics.debugInfo.usedGPUMemMB, Graphics.debugInfo.totalGPUMemMB);
					}

					perfText.AppendF("FPS: {}, tFPS: {:0000}, RawDelta: {:0.0000}s, Delta: {:0.0000}s, Freeze: {}\nVSync: {}, Draw Calls: {:00}, Tri Count: {:0000}, {}Sound Count: {:00} ({:00} audible)\n", Time.FPS, tFPS, Time.RawDelta, Time.Delta, Time.freeze > 0, System.window.VSync, Graphics.DebugInfo.drawCalls, Graphics.DebugInfo.triCount, gfxMem, Audio.SoundCount, Audio.AudibleSoundCount);
				}

#if USE_PERF
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
								if (ranking.Count == perfTrackDisplayCount) // Remove if we would push beyond what we need
									ranking.PopBack();
	
								ranking.Insert(i, pair);
								inserted = true;
								break;
							}
						}
	
						if (!inserted && ranking.Count < perfTrackDisplayCount)
							ranking.Add(pair);
					}
	
					for (let pair in ranking) // Draw sections
					{
						perfText.AppendF("{:0.000}ms {}\n", (float)pair.value.Ticks / TimeSpan.[Friend]TicksPerMillisecond, pair.key);
					}
				}
#endif

				batch.Text(font, perfText, .(scale, 4 * scale), textScale, .Zero, 0, .White);
			}
		}

		[Inline]
		public static Dictionary<String, TimeSpan>.Enumerator EnumerateTrackingResults()
		{
			return sectionDurationsRead.GetEnumerator();
		}
	}
}
