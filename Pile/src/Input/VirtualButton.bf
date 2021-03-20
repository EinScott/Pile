using System.Collections;
using System;

using internal Pile;

namespace Pile
{
	class VirtualButton
	{
		public abstract class Node
		{
			public abstract bool Pressed(float buffer, int64 lastBufferConsumedTime);
			public abstract bool Down { get; }
			public abstract bool Released { get; }
			public abstract bool Repeated(float delay, float interval);
			protected internal abstract void Update();
		}

		public class KeyNode : Node
		{
		    public Keys key;

		    public override bool Pressed(float buffer, int64 lastBufferConsumedTime)
		    {
		        if (Core.Input.Keyboard.Pressed(key))
		            return true;

		        var timestamp = Core.Input.Keyboard.Timestamp(key);
		        var time = Time.Duration.Ticks;

		        if (time - timestamp <= buffer * TimeSpan.TicksPerSecond && timestamp > lastBufferConsumedTime)
		            return true;

		        return false;
		    }

		    public override bool Down => Core.Input.Keyboard.Down(key);
		    public override bool Released => Core.Input.Keyboard.Released(key);
		    public override bool Repeated(float delay, float interval) => Core.Input.Keyboard.Repeated(key, delay, interval);
		    protected internal override void Update() { }

		    internal this(Keys key)
		    {
		        this.key = key;
		    }
		}

		public class MouseButtonNode : Node
		{
		    public MouseButtons mouseButton;

		    public override bool Pressed(float buffer, int64 lastBufferConsumedTime)
		    {
		        if (Core.Input.Mouse.Pressed(mouseButton))
		            return true;

		        var timestamp = Core.Input.Mouse.Timestamp(mouseButton);
		        var time = Time.Duration.Ticks;

		        if (time - timestamp <= buffer * TimeSpan.TicksPerSecond && timestamp > lastBufferConsumedTime)
		            return true;

		        return false;
		    }

		    public override bool Down => Core.Input.Mouse.Down(mouseButton);
		    public override bool Released => Core.Input.Mouse.Released(mouseButton);
		    public override bool Repeated(float delay, float interval) => Core.Input.Mouse.Repeated(mouseButton, delay, interval);
		    protected internal override void Update() { }

		    internal this(MouseButtons mouseButton)
		    {
		        this.mouseButton = mouseButton;
		    }
		}

		public class ButtonNode : Node
		{
		    public int index;
		    public Buttons button;

		    public override bool Pressed(float buffer, int64 lastBufferConsumedTime)
		    {
		        if (Core.Input.state.controllers[index].Pressed(button))
		            return true;

		        var timestamp = Core.Input.state.controllers[index].Timestamp(button);
		        var time = Time.Duration.Ticks;

		        if (time - timestamp <= buffer * TimeSpan.TicksPerSecond && timestamp > lastBufferConsumedTime)
		            return true;

		        return false;
		    }

		    public override bool Down => Core.Input.state.controllers[index].Down(button);
		    public override bool Released => Core.Input.state.controllers[index].Released(button);
		    public override bool Repeated(float delay, float interval) => Core.Input.state.controllers[index].Repeated(button, delay, interval);
		    protected internal override void Update() { }

		    internal this(int controller, Buttons button)
		    {
		        this.index = controller < (int)Core.Input.maxControllers ? controller : 0;
		        this.button = button;
		    }
		}

		public class AxisNode : Node
		{
		    public int index;
		    public Axes axis;
		    public float threshold;

		    float pressedTimestamp;
		    const float AXIS_EPSILON = 0.00001f;

		    public override bool Pressed(float buffer, int64 lastBufferConsumedTime)
		    {
		        if (Pressed())
		            return true;

		        var time = Time.Duration.Ticks;

		        if (time - pressedTimestamp <= buffer * TimeSpan.TicksPerSecond && pressedTimestamp > lastBufferConsumedTime)
		            return true;

		        return false;
		    }

		    public override bool Down
		    {
		        get
		        {
		            if (Math.Abs(threshold) <= AXIS_EPSILON)
		                return Math.Abs(Core.Input.state.controllers[index].Axis(axis)) > AXIS_EPSILON;

		            if (threshold < 0)
		                return Core.Input.state.controllers[index].Axis(axis) <= threshold;
		            
		            return Core.Input.state.controllers[index].Axis(axis) >= threshold;
		        }
		    }

		    public override bool Released
		    {
		        get
		        {
		            if (Math.Abs(threshold) <= AXIS_EPSILON)
		                return Math.Abs(Core.Input.lastState.controllers[index].Axis(axis)) > AXIS_EPSILON && Math.Abs(Core.Input.state.controllers[index].Axis(axis)) < AXIS_EPSILON;

		            if (threshold < 0)
		                return Core.Input.lastState.controllers[index].Axis(axis) <= threshold && Core.Input.state.controllers[index].Axis(axis) > threshold;

		            return Core.Input.lastState.controllers[index].Axis(axis) >= threshold && Core.Input.state.controllers[index].Axis(axis) < threshold;
		        }
		    }

		    public override bool Repeated(float delay, float interval) => false;

		    private bool Pressed()
		    {
		        if (Math.Abs(threshold) <= AXIS_EPSILON)
		            return (Math.Abs(Core.Input.lastState.controllers[index].Axis(axis)) < AXIS_EPSILON && Math.Abs(Core.Input.state.controllers[index].Axis(axis)) > AXIS_EPSILON);

		        if (threshold < 0)
		            return (Core.Input.lastState.controllers[index].Axis(axis) > threshold && Core.Input.state.controllers[index].Axis(axis) <= threshold);
		        
		        return (Core.Input.lastState.controllers[index].Axis(axis) < threshold && Core.Input.state.controllers[index].Axis(axis) >= threshold);
		    }

		    protected internal override void Update()
		    {
		        if (Pressed())
		            pressedTimestamp = Core.Input.state.controllers[index].Timestamp(axis);
		    }

		    internal this(int controller, Axes axis, float threshold)
		    {
		        this.index = controller < (int)Core.Input.maxControllers ? controller : 0;
		        this.axis = axis;
		        this.threshold = threshold;
		    }
		}

		public readonly List<Node> Nodes = new List<Node>() ~ DeleteContainerAndItems!(_);
		public float repeatDelay;
		public float repeatInterval;
		public float buffer;

		int64 lastBufferConsumeTime;

		public this(float buffer = 0f)
		{
			Core.Input.virtualButtons.Add(this);

			this.buffer = buffer;
			repeatInterval = Core.Input.repeatInterval;
			repeatDelay = Core.Input.repeatDelay;
		}

		public ~this()
		{
			// Don't remove from the list when we are about to delete the list
			if (!Core.Input.deleting) Core.Input.virtualButtons.Remove(this);
		}

		internal void Update()
		{
			for (int i = 0; i < Nodes.Count; i ++)
				Nodes[i].Update();
		}

		public bool Pressed
		{
		    get
		    {
		        for (int i = 0; i < Nodes.Count; i++)
		            if (Nodes[i].Pressed(buffer, lastBufferConsumeTime))
		                return true;

		        return false;
		    }
		}

		public bool Down
		{
		    get
		    {
		        for (int i = 0; i < Nodes.Count; i++)
		            if (Nodes[i].Down)
		                return true;

		        return false;
		    }
		}

		public bool Released
		{
		    get
		    {
		        for (int i = 0; i < Nodes.Count; i++)
		            if (Nodes[i].Released)
		                return true;

		        return false;
		    }
		}

		public bool Repeated
		{
		    get
		    {
		        for (int i = 0; i < Nodes.Count; i++)
		            if (Nodes[i].Pressed(buffer, lastBufferConsumeTime) || Nodes[i].Repeated(repeatDelay, repeatInterval))
		                return true;

		        return false;
		    }
		}

		public void ConsumeBuffer()
		{
		    lastBufferConsumeTime = Time.Duration.Ticks;
		}

		public void AddKeyboard(params Keys[] keys)
		{
		    for (var key in keys)
		        Nodes.Add(new KeyNode(key));
		}

		public void AddMouse(params MouseButtons[] buttons)
		{
		    for (var button in buttons)
		        Nodes.Add(new MouseButtonNode(button));
		}

		public void AddControllerButton(int controller, params Buttons[] buttons)
		{
		    for (var button in buttons)
		        Nodes.Add(new ButtonNode(controller, button));
		}

		public void AddControllerAxis(int controller, Axes axis, float threshold)
		{
		    Nodes.Add(new AxisNode(controller, axis, threshold));
		}

		public void Clear()
		{
			for (int i = 0; i < Nodes.Count; i ++)
				delete Nodes[i];
		    Nodes.Clear();
		}
	}
}
