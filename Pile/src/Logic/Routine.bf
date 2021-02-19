using System;
using System.Diagnostics;

namespace Pile
{
	public enum RoutineReturn
	{
		case Continue; // Simply returns
		case Break; // Stop the routine and lastly call end if not null

		case WaitCycles(int cycles); // Wait [cycles] update cycles
		case WaitSeconds(float seconds); // Wait [seconds] seconds
		case WaitRawSeconds(float seconds); // Wait [seconds] seconds, not affected by Time.Scale
		case WaitRoutine(IRoutine routine); // Wait until routine.Done == true

		case ChangePhase(int index); // Change current index of phase array
	}

	public interface IRoutine
	{
		public bool Done { get; }

		public void Start();
		public void Update();
		public void Abort();
	}

	/// For convenience, you probably just want TData to be a tuple like (float amount, int iter, int end, Routine wait) or something
	public class Routine<TData> : IRoutine where TData : struct
	{
		public function RoutineReturn RoutineUpdate(ref TData data);
		public function void RoutineEnd(ref TData data);

		readonly RoutineUpdate StartPhase; // @do expand and switch function pointers?; seperate state machine
		readonly RoutineUpdate[] UpdatePhases;
		readonly RoutineEnd EndPhase;

		TData data = default;
		RoutineReturn lastReturn = .Break;
		int phase = 0;

		public bool Done => lastReturn == .Break;
		public ref TData Data => ref data;

		public RoutineReturn State => lastReturn;

		/// Single phase constructor
		public this(RoutineUpdate startPhase, RoutineUpdate updatePhase, RoutineEnd endPhase = null)
		{
			Debug.Assert(startPhase != null && updatePhase != null, "Routine delegates Start and Update can't be null");

			StartPhase = startPhase;
			UpdatePhases = new RoutineUpdate[1](updatePhase);
			EndPhase = endPhase;
		}

		/// n-Phase contructor
		public this(RoutineUpdate startPhase, RoutineEnd endPhase, params RoutineUpdate[] updatePhases)
		{
			Debug.Assert(startPhase != null && updatePhases.Count > 0 && updatePhases[0] != null, "Routine delegates Start and Update can't be null");

			StartPhase = startPhase;
			UpdatePhases = new RoutineUpdate[updatePhases.Count];
			updatePhases.CopyTo(Span<RoutineUpdate>(UpdatePhases));
			EndPhase = endPhase;
		}

		public ~this()
		{
			// Ensure ending routine
			if (lastReturn != .Break)
				Abort();

			delete UpdatePhases;
		}

		public void Start() => Start(default);

		public void Start(TData startData, int startPhase = 0)
		{
			if (lastReturn != .Break) return; // Cant run more than once at a time

			// Prepare
			lastReturn = .Continue;
			data = startData;
			phase = Math.Max(Math.Min(startPhase, UpdatePhases.Count - 1), 0);

			Handle(StartPhase(ref data));
		}

		/// This should probably be in your regular update function since it uses Time.Delta and RawDelta for delays
		public void Update()
		{
			switch (lastReturn)
			{
				// Not active
			case .Break: return;

				// Wait
			case .WaitCycles(var cycles): // Wait [cycles] update cycles
				if (cycles <= 0) lastReturn = .Continue;
				else lastReturn = .WaitCycles(--cycles); // waiting one means skipping one update, so decrease later here

			case .WaitSeconds(var seconds): // Wait [seconds] seconds
				seconds -= Time.Delta;
				if (seconds <= 0) lastReturn = .Continue;
				else lastReturn = .WaitSeconds(seconds);

			case .WaitRawSeconds(var seconds): // Wait [seconds] seconds unscaled
				seconds -= Time.RawDelta;
				if (seconds <= 0) lastReturn = .Continue;
				else lastReturn = .WaitRawSeconds(seconds);

			case .WaitRoutine(let routine): // Wait until routine.Done == true
				if (routine.Done) lastReturn = .Continue;

			default:
				// INVALID OR IGNORED
			}

			// Run routine
			if (lastReturn == .Continue)
			{
				let func = ref UpdatePhases[phase];
				Handle(func(ref data));
			}
		}

		public void Abort()
		{
			if (lastReturn == .Break) return;

			if (EndPhase != null)
				EndPhase(ref data);

			// Reset
			lastReturn = .Break;
			//data = default;
		}

		[Inline]
		void Handle(RoutineReturn ret)
		{
			switch (ret)
			{
			case .Continue: // Simply returns
				lastReturn = .Continue;

				// Break (here lastReturn will be set to .Break by Abort) 
			case .Break: // Stop the routine and lastly call end
				Abort();

				// Change update delegate
			case .ChangePhase(let newPhase):
				if (newPhase > 0 && newPhase < UpdatePhases.Count)
					phase = newPhase;

				// Wait => pass these on to update
			case .WaitCycles, .WaitSeconds, .WaitRawSeconds, .WaitRoutine:
				lastReturn = ret;
			}
		}
	}
}
