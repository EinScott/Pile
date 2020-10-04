using System;
using System.Collections;

namespace Pile
{
	public class VirtualAxis
	{
	    public enum Overlaps
	    {
	        CancelOut,
	        TakeOlder,
	        TakeNewer
	    };

	    public abstract class Node
	    {
	        public abstract float Value(bool deadzone);
	        public abstract double Timestamp { get; }
	    }

	    public class KeyNode : Node
	    {
	        public Input input;
	        public Keys key;
	        public bool positive;

	        public override float Value(bool deadzone) => (input.Keyboard.Down(key) ? (positive ? 1 : -1) : 0);
	        public override double Timestamp => input.Keyboard.Timestamp(key);

	        public this(Input input, Keys key, bool positive)
	        {
	            this.input = input;
	            this.key = key;
	            this.positive = positive;
	        }
	    }

	    public class ButtonNode : Node
	    {
	        public Input input;
	        public int index;
	        public Buttons button;
	        public bool positive;

	        public override float Value(bool deadzone) => (input.state.[Friend]controllers[index].Down(button) ? (positive ? 1 : -1) : 0);
	        public override double Timestamp => input.state.[Friend]controllers[index].Timestamp(button);

	        public this(Input input, int controller, Buttons button, bool positive)
	        {
	            this.input = input;
	            this.index = controller;
	            this.button = button;
	            this.positive = positive;
	        }
	    }

	    public class AxisNode : Node
	    {
	        public Input input;
	        public int index;
	        public Axes axis;
	        public bool positive;
	        public float deadzone;

	        public override float Value(bool deadzone)
	        {
	            if (!deadzone || Math.Abs(input.state.[Friend]controllers[index].Axis(axis)) >= this.deadzone)
	                return input.state.[Friend]controllers[index].Axis(axis) * (positive ? 1 : -1);
	            return 0f;
	        }

	        public override double Timestamp
	        {
	            get
	            {
	                if (Math.Abs(input.state.[Friend]controllers[index].Axis(axis)) < deadzone)
	                    return 0;
	                return input.state.[Friend]controllers[index].Timestamp(axis);
	            }
	        }

	        public this(Input input, int controller, Axes axis, float deadzone, bool positive)
	        {
	            this.input = input;
	            this.index = controller;
	            this.axis = axis;
	            this.deadzone = deadzone;
	            this.positive = positive;
	        }
	    }

	    public float Value => GetValue(true);
	    public float ValueNoDeadzone => GetValue(false);

	    public int IntValue => Math.Sign(Value);
	    public int IntValueNoDeadzone => Math.Sign(ValueNoDeadzone);

	    public readonly Input input;
	    public readonly List<Node> Nodes = new List<Node>() ~ DeleteContainerAndItems!(_);
	    public Overlaps overlapBehaviour;

	    private const float EPSILON = 0.00001f;

	    public this(Overlaps overlapBehaviour = .CancelOut)
	    {
	        input = Core.Input;
	        this.overlapBehaviour = overlapBehaviour;
	    }

	    private float GetValue(bool deadzone)
	    {
	        var value = 0f;

	        if (overlapBehaviour == Overlaps.CancelOut)
	        {
	            for (var input in Nodes)
	                value += input.Value(deadzone);
	            value = Math.Clamp(value, -1, 1);
	        }
	        else if (overlapBehaviour == Overlaps.TakeNewer)
	        {
	            var timestamp = 0d;
	            for (int i = 0; i < Nodes.Count; i++)
	            {
	                var time = Nodes[i].Timestamp;
	                var val = Nodes[i].Value(deadzone);

	                if (time > 0 && Math.Abs(val) > EPSILON && time > timestamp)
	                {
	                    value = val;
	                    timestamp = time;
	                }
	            }
	        }
	        else if (overlapBehaviour == Overlaps.TakeOlder)
	        {
	            var timestamp = double.MaxValue;
	            for (int i = 0; i < Nodes.Count; i++)
	            {
	                var time = Nodes[i].Timestamp;
	                var val = Nodes[i].Value(deadzone);

	                if (time > 0 && Math.Abs(val) > EPSILON && time < timestamp)
	                {
	                    value = val;
	                    timestamp = time;
	                }
	            }
	        }

	        return value;
	    }

	    public void Add(Keys negative, Keys positive)
	    {
	        Nodes.Add(new KeyNode(input, negative, false));
	        Nodes.Add(new KeyNode(input, positive, true));
	    }

	    public void Add(Keys key, bool isPositive)
	    {
	        Nodes.Add(new KeyNode(input, key, isPositive));
	    }

	    public void Add(int controller, Buttons negative, Buttons positive)
	    {
	        Nodes.Add(new ButtonNode(input, controller, negative, false));
	        Nodes.Add(new ButtonNode(input, controller, positive, true));
	    }

	    public void Add(int controller, Buttons button, bool isPositive)
	    {
	        Nodes.Add(new ButtonNode(input, controller, button, isPositive));
	    }

	    public void Add(int controller, Axes axis, float deadzone = 0f)
	    {
	        Nodes.Add(new AxisNode(input, controller, axis, deadzone, true));
	    }

	    public void Add(int controller, Axes axis, bool inverse, float deadzone = 0f)
	    {
	        Nodes.Add(new AxisNode(input, controller, axis, deadzone, !inverse));
	    }

	    public void Clear()
	    {
			for (int i = 0; i < Nodes.Count; i ++)
				delete Nodes[i];
	        Nodes.Clear();
	    }

	}
}
