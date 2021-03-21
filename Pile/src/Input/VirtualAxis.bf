using System;
using System.Collections;

using internal Pile;

namespace Pile
{
	class VirtualAxis
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
	        public Keys key;
	        public bool positive;

			[Inline]
	        public override float Value(bool deadzone) => (Input.Keyboard.Down(key) ? (positive ? 1 : -1) : 0);
			[Inline]
	        public override double Timestamp => Input.Keyboard.Timestamp(key);

	        internal this(Keys key, bool positive)
	        {
	            this.key = key;
	            this.positive = positive;
	        }
	    }

	    public class ButtonNode : Node
	    {
	        public int index;
	        public Buttons button;
	        public bool positive;

	        public override float Value(bool deadzone) => (Input.state.controllers[index].Down(button) ? (positive ? 1 : -1) : 0);
			[Inline]
	        public override double Timestamp => Input.state.controllers[index].Timestamp(button);

	        internal this(int controller, Buttons button, bool positive)
	        {
	            this.index = controller;
	            this.button = button;
	            this.positive = positive;
	        }
	    }

	    public class AxisNode : Node
	    {
	        public int index;
	        public Axes axis;
	        public bool positive;
	        public float deadzone;

	        public override float Value(bool deadzone)
	        {
	            if (!deadzone || Math.Abs(Input.state.controllers[index].Axis(axis)) >= this.deadzone)
	                return Input.state.controllers[index].Axis(axis) * (positive ? 1 : -1);
	            return 0f;
	        }

	        public override double Timestamp
	        {
	            get
	            {
	                if (Math.Abs(Input.state.controllers[index].Axis(axis)) < deadzone)
	                    return 0;
	                return Input.state.controllers[index].Timestamp(axis);
	            }
	        }

	        internal this(int controller, Axes axis, float deadzone, bool positive)
	        {
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

	    public readonly List<Node> Nodes = new List<Node>() ~ DeleteContainerAndItems!(_);
	    public Overlaps overlapBehaviour;

	    const float EPSILON = 0.00001f;

	    public this(Overlaps overlapBehaviour = .CancelOut)
	    {
	        this.overlapBehaviour = overlapBehaviour;
	    }

	    float GetValue(bool deadzone)
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
	        Nodes.Add(new KeyNode(negative, false));
	        Nodes.Add(new KeyNode(positive, true));
	    }

	    public void Add(Keys key, bool isPositive)
	    {
	        Nodes.Add(new KeyNode(key, isPositive));
	    }

	    public void Add(int controller, Buttons negative, Buttons positive)
	    {
	        Nodes.Add(new ButtonNode(controller, negative, false));
	        Nodes.Add(new ButtonNode(controller, positive, true));
	    }

	    public void Add(int controller, Buttons button, bool isPositive)
	    {
	        Nodes.Add(new ButtonNode(controller, button, isPositive));
	    }

	    public void Add(int controller, Axes axis, float deadzone = 0f)
	    {
	        Nodes.Add(new AxisNode(controller, axis, deadzone, true));
	    }

	    public void Add(int controller, Axes axis, bool inverse, float deadzone = 0f)
	    {
	        Nodes.Add(new AxisNode(controller, axis, deadzone, !inverse));
	    }

	    public void Clear()
	    {
			for (int i = 0; i < Nodes.Count; i ++)
				delete Nodes[i];
	        Nodes.Clear();
	    }

	}
}
