using System;

namespace Pile
{
	public class VirtualStick
	{
		public class VirtualStick
		{
		    public VirtualAxis horizontal ~ delete _;
		    public VirtualAxis vertical ~ delete _;

		    public float circularDeadzone = 0f;

		    public Vector Value
		    {
		        get
		        {
		            var result = Vector(horizontal.Value, vertical.Value);
		            if (circularDeadzone != 0 && result.Length < circularDeadzone)
		                return Vector.Zero;
		            return result;
		        }
		    }
		    public Vector ValueNoDeadzone => Vector(horizontal.ValueNoDeadzone, vertical.ValueNoDeadzone);
		    public Point IntValue
		    {
		        get
		        {
		            var result = Value;
		            return Point(Math.Sign(result.X), Math.Sign(result.Y));
		        }
		    }
		    public Point IntValueNoDeadzone => Point(horizontal.IntValueNoDeadzone, vertical.IntValueNoDeadzone);

		    public this(float circularDeadzone = 0f)
		    {
		        horizontal = new VirtualAxis();
		        vertical = new VirtualAxis();
		        this.circularDeadzone = circularDeadzone;
		    }

		    public this(VirtualAxis.Overlaps overlapBehaviour, float circularDeadzone = 0f)
		    {
		        horizontal = new VirtualAxis(overlapBehaviour);
		        vertical = new VirtualAxis(overlapBehaviour);
		        this.circularDeadzone = circularDeadzone;
		    }

		    public VirtualStick Add(Keys left, Keys right, Keys up, Keys down)
		    {
		        horizontal.Add(left, right);
		        vertical.Add(up, down);
		        return this;
		    }

		    public VirtualStick Add(int controller, Buttons left, Buttons right, Buttons up, Buttons down)
		    {
		        horizontal.Add(controller, left, right);
		        vertical.Add(controller, up, down);
		        return this;
		    }

		    public VirtualStick Add(int controller, Axes horizontal, Axes vertical, float deadzoneHorizontal = 0f, float deadzoneVertical = 0f)
		    {
		        this.horizontal.Add(controller, horizontal, deadzoneHorizontal);
		        this.vertical.Add(controller, vertical, deadzoneVertical);
		        return this;
		    }

		    public VirtualStick AddLeftJoystick(int controller, float deadzoneHorizontal = 0, float deadzoneVertical = 0)
		    {
		        horizontal.Add(controller, Axes.LeftX, deadzoneHorizontal);
		        vertical.Add(controller, Axes.LeftY, deadzoneVertical);
		        return this;
		    }

		    public VirtualStick AddRightJoystick(int controller, float deadzoneHorizontal = 0, float deadzoneVertical = 0)
		    {
		        horizontal.Add(controller, Axes.RightX, deadzoneHorizontal);
		        vertical.Add(controller, Axes.RightY, deadzoneVertical);
		        return this;
		    }

		    public void Clear()
		    {
		        horizontal.Clear();
		        vertical.Clear();
		    }

		}
	}
}
