using System.Collections;
using System;

namespace Pile
{
	public class VirtualButton
	{
		public abstract class Node
		{
			public abstract bool Pressed(float buffer, int64 lastBufferConsumedTime);
			public abstract bool Down { get; }
			public abstract bool Released { get; }
			public abstract bool Repeated(float delay, float interval);
			protected abstract void Update();
		}

		public class KeyNode : Node
		{
		    public Input input;
		    public Keys key;

		    public override bool Pressed(float buffer, int64 lastBufferConsumedTime)
		    {
		        if (input.Keyboard.Pressed(key))
		            return true;

		        var timestamp = input.Keyboard.Timestamp(key);
		        var time = Time.Duration.Ticks;
		        
		        if (time - timestamp <= buffer * TimeSpan.TicksPerSecond && timestamp > lastBufferConsumedTime)
		            return true;

		        return false;
		    }

		    public override bool Down => input.Keyboard.Down(key);
		    public override bool Released => input.Keyboard.Released(key);
		    public override bool Repeated(float delay, float interval) => input.Keyboard.Repeated(key, delay, interval);
		    protected override void Update() { }

		    public this(Input input, Keys key)
		    {
		        this.input = input;
		        this.key = key;
		    }
		}

		public class MouseButtonNode : Node
		{
		    public Input input;
		    public MouseButtons mouseButton;

		    public override bool Pressed(float buffer, int64 lastBufferConsumedTime)
		    {
		        if (input.Mouse.Pressed(mouseButton))
		            return true;

		        var timestamp = input.Mouse.Timestamp(mouseButton);
		        var time = Time.Duration.Ticks;

		        if (time - timestamp <= buffer * TimeSpan.TicksPerSecond && timestamp > lastBufferConsumedTime)
		            return true;

		        return false;
		    }

		    public override bool Down => input.Mouse.Down(mouseButton);
		    public override bool Released => input.Mouse.Released(mouseButton);
		    public override bool Repeated(float delay, float interval) => input.Mouse.Repeated(mouseButton, delay, interval);
		    protected override void Update() { }

		    public this(Input input, MouseButtons mouseButton)
		    {
		        this.input = input;
		        this.mouseButton = mouseButton;
		    }
		}

		public class ButtonNode : Node
		{
		    public Input input;
		    public int index;
		    public Buttons button;

		    public override bool Pressed(float buffer, int64 lastBufferConsumedTime)
		    {
		        if (input.state.[Friend]controllers[index].Pressed(button))
		            return true;

		        var timestamp = input.state.[Friend]controllers[index].Timestamp(button);
		        var time = Time.Duration.Ticks;

		        if (time - timestamp <= buffer * TimeSpan.TicksPerSecond && timestamp > lastBufferConsumedTime)
		            return true;

		        return false;
		    }

		    public override bool Down => input.state.[Friend]controllers[index].Down(button);
		    public override bool Released => input.state.[Friend]controllers[index].Released(button);
		    public override bool Repeated(float delay, float interval) => input.state.[Friend]controllers[index].Repeated(button, delay, interval);
		    protected override void Update() { }

		    public this(Input input, int controller, Buttons button)
		    {
		        this.input = input;
		        this.index = controller < (int)input.[Friend]maxControllers ? controller : 0;
		        this.button = button;
		    }
		}

		public class AxisNode : Node
		{
		    public Input input;
		    public int index;
		    public Axes axis;
		    public float threshold;

		    private float pressedTimestamp;
		    private const float AXIS_EPSILON = 0.00001f;

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
		                return Math.Abs(input.state.[Friend]controllers[index].Axis(axis)) > AXIS_EPSILON;

		            if (threshold < 0)
		                return input.state.[Friend]controllers[index].Axis(axis) <= threshold;
		            
		            return input.state.[Friend]controllers[index].Axis(axis) >= threshold;
		        }
		    }

		    public override bool Released
		    {
		        get
		        {
		            if (Math.Abs(threshold) <= AXIS_EPSILON)
		                return Math.Abs(input.lastState.[Friend]controllers[index].Axis(axis)) > AXIS_EPSILON && Math.Abs(input.state.[Friend]controllers[index].Axis(axis)) < AXIS_EPSILON;

		            if (threshold < 0)
		                return input.lastState.[Friend]controllers[index].Axis(axis) <= threshold && input.state.[Friend]controllers[index].Axis(axis) > threshold;

		            return input.lastState.[Friend]controllers[index].Axis(axis) >= threshold && input.state.[Friend]controllers[index].Axis(axis) < threshold;
		        }
		    }

		    public override bool Repeated(float delay, float interval) => false;

		    private bool Pressed()
		    {
		        if (Math.Abs(threshold) <= AXIS_EPSILON)
		            return (Math.Abs(input.lastState.[Friend]controllers[index].Axis(axis)) < AXIS_EPSILON && Math.Abs(input.state.[Friend]controllers[index].Axis(axis)) > AXIS_EPSILON);

		        if (threshold < 0)
		            return (input.lastState.[Friend]controllers[index].Axis(axis) > threshold && input.state.[Friend]controllers[index].Axis(axis) <= threshold);
		        
		        return (input.lastState.[Friend]controllers[index].Axis(axis) < threshold && input.state.[Friend]controllers[index].Axis(axis) >= threshold);
		    }

		    protected override void Update()
		    {
		        if (Pressed())
		            pressedTimestamp = input.state.[Friend]controllers[index].Timestamp(axis);
		    }

		    public this(Input input, int controller, Axes axis, float threshold)
		    {
		        this.input = input;
		        this.index = controller < (int)input.[Friend]maxControllers ? controller : 0;
		        this.axis = axis;
		        this.threshold = threshold;
		    }
		}

		public readonly Input input;

		public readonly List<Node> Nodes = new List<Node>() ~ DeleteContainerAndItems!(_);
		public float repeatDelay;
		public float repeatInterval;
		public float buffer;

		private int64 lastBufferConsumeTime;

		public this(float buffer = 0f)
		{
			input = Core.Input;
			input.[Friend]virtualButtons.Add(this);

			this.buffer = buffer;
			repeatInterval = input.repeatInterval;
			repeatDelay = input.repeatDelay;
		}

		bool deletingList; // Don't remove from the list when we are about to delete the list
		public ~this()
		{
			if (!deletingList) input.[Friend]virtualButtons.Remove(this);
		}

		void Update()
		{
			for (int i = 0; i < Nodes.Count; i ++)
				Nodes[i].[Friend]Update();
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

		public VirtualButton Add(params Keys[] keys)
		{
		    for (var key in keys)
		        Nodes.Add(new KeyNode(input, key));
			return this;
		}

		public VirtualButton Add(params MouseButtons[] buttons)
		{
		    for (var button in buttons)
		        Nodes.Add(new MouseButtonNode(input, button));
			return this;
		}

		public VirtualButton Add(int controller, params Buttons[] buttons)
		{
		    for (var button in buttons)
		        Nodes.Add(new ButtonNode(input, controller, button));
			return this;
		}

		public VirtualButton Add(int controller, Axes axis, float threshold)
		{
		    Nodes.Add(new AxisNode(input, controller, axis, threshold));
			return this;
		}

		public void Clear()
		{
			for (int i = 0; i < Nodes.Count; i ++)
				delete Nodes[i];
		    Nodes.Clear();
		}
	}
}