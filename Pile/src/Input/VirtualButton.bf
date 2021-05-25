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
		        if (Input.Keyboard.Pressed(key))
		            return true;

		        var timestamp = Input.Keyboard.Timestamp(key);
		        var time = Time.Duration.Ticks;

		        if (time - timestamp <= buffer * TimeSpan.TicksPerSecond && timestamp > lastBufferConsumedTime)
		            return true;

		        return false;
		    }

			[Inline]
		    public override bool Down => Input.Keyboard.Down(key);
			[Inline]
		    public override bool Released => Input.Keyboard.Released(key);
			[Inline]
		    public override bool Repeated(float delay, float interval) => Input.Keyboard.Repeated(key, delay, interval);
			[SkipCall]
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
		        if (Input.Mouse.Pressed(mouseButton))
		            return true;

		        var timestamp = Input.Mouse.Timestamp(mouseButton);
		        var time = Time.Duration.Ticks;

		        if (time - timestamp <= buffer * TimeSpan.TicksPerSecond && timestamp > lastBufferConsumedTime)
		            return true;

		        return false;
		    }

			[Inline]
		    public override bool Down => Input.Mouse.Down(mouseButton);
			[Inline]
		    public override bool Released => Input.Mouse.Released(mouseButton);
			[Inline]
		    public override bool Repeated(float delay, float interval) => Input.Mouse.Repeated(mouseButton, delay, interval);
			[SkipCall]
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
		        if (Input.state.controllers[index].Pressed(button))
		            return true;

		        var timestamp = Input.state.controllers[index].Timestamp(button);
		        var time = Time.Duration.Ticks;

		        if (time - timestamp <= buffer * TimeSpan.TicksPerSecond && timestamp > lastBufferConsumedTime)
		            return true;

		        return false;
		    }

			[Inline]
		    public override bool Down => Input.state.controllers[index].Down(button);
			[Inline]
		    public override bool Released => Input.state.controllers[index].Released(button);
			[Inline]
		    public override bool Repeated(float delay, float interval) => Input.state.controllers[index].Repeated(button, delay, interval);
			[SkipCall]
		    protected internal override void Update() { }

		    internal this(Controllers controller, Buttons button)
		    {
		        this.index = controller.Underlying;
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
		                return Math.Abs(Input.state.controllers[index].Axis(axis)) > AXIS_EPSILON;

		            if (threshold < 0)
		                return Input.state.controllers[index].Axis(axis) <= threshold;
		            
		            return Input.state.controllers[index].Axis(axis) >= threshold;
		        }
		    }

		    public override bool Released
		    {
		        get
		        {
		            if (Math.Abs(threshold) <= AXIS_EPSILON)
		                return Math.Abs(Input.lastState.controllers[index].Axis(axis)) > AXIS_EPSILON && Math.Abs(Input.state.controllers[index].Axis(axis)) < AXIS_EPSILON;

		            if (threshold < 0)
		                return Input.lastState.controllers[index].Axis(axis) <= threshold && Input.state.controllers[index].Axis(axis) > threshold;

		            return Input.lastState.controllers[index].Axis(axis) >= threshold && Input.state.controllers[index].Axis(axis) < threshold;
		        }
		    }

			[Inline]
		    public override bool Repeated(float delay, float interval) => false;

		    private bool Pressed()
		    {
		        if (Math.Abs(threshold) <= AXIS_EPSILON)
		            return (Math.Abs(Input.lastState.controllers[index].Axis(axis)) < AXIS_EPSILON && Math.Abs(Input.state.controllers[index].Axis(axis)) > AXIS_EPSILON);

		        if (threshold < 0)
		            return (Input.lastState.controllers[index].Axis(axis) > threshold && Input.state.controllers[index].Axis(axis) <= threshold);
		        
		        return (Input.lastState.controllers[index].Axis(axis) < threshold && Input.state.controllers[index].Axis(axis) >= threshold);
		    }

		    protected internal override void Update()
		    {
		        if (Pressed())
		            pressedTimestamp = Input.state.controllers[index].Timestamp(axis);
		    }

		    internal this(Controllers controller, Axes axis, float threshold)
		    {
		        this.index = controller.Underlying;
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
			Input.virtualButtons.Add(this);

			this.buffer = buffer;
			repeatInterval = Input.repeatInterval;
			repeatDelay = Input.repeatDelay;
		}

		public ~this()
		{
			// Don't remove from the list when we are about to delete the list
			if (!Input.deleting) Input.virtualButtons.Remove(this);
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

		public void AddControllerButton(Controllers controller, params Buttons[] buttons)
		{
		    for (var button in buttons)
		        Nodes.Add(new ButtonNode(controller, button));
		}

		public void AddControllerAxis(Controllers controller, Axes axis, float threshold)
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
