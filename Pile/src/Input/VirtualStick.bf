using System;

namespace Pile
{
	class VirtualStick
	{
	    public VirtualAxis horizontal ~ delete _;
	    public VirtualAxis vertical ~ delete _;

	    public float circularDeadzone = 0f;

	    public Vector2 Value
	    {
	        get
	        {
	            var result = Vector2(horizontal.Value, vertical.Value);
	            if (circularDeadzone != 0 && result.Length < circularDeadzone)
	                return Vector2.Zero;
	            return result;
	        }
	    }
	    public Vector2 ValueNoDeadzone => Vector2(horizontal.ValueNoDeadzone, vertical.ValueNoDeadzone);
	    public Point2 IntValue
	    {
	        get
	        {
	            var result = Value;
	            return Point2(Math.Sign(result.X), Math.Sign(result.Y));
	        }
	    }
	    public Point2 IntValueNoDeadzone => Point2(horizontal.IntValueNoDeadzone, vertical.IntValueNoDeadzone);

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

	    public void Add(Keys left, Keys right, Keys up, Keys down)
	    {
	        horizontal.Add(left, right);
	        vertical.Add(up, down);
	    }

	    public void Add(Controllers controller, Buttons left, Buttons right, Buttons up, Buttons down)
	    {
	        horizontal.Add(controller, left, right);
	        vertical.Add(controller, up, down);
	    }

	    public void Add(Controllers controller, Axes horizontal, Axes vertical, float deadzoneHorizontal = 0f, float deadzoneVertical = 0f)
	    {
	        this.horizontal.Add(controller, horizontal, deadzoneHorizontal);
	        this.vertical.Add(controller, vertical, deadzoneVertical);
	    }

	    public void AddLeftJoystick(Controllers controller, float deadzoneHorizontal = 0, float deadzoneVertical = 0)
	    {
	        horizontal.Add(controller, Axes.LeftX, deadzoneHorizontal);
	        vertical.Add(controller, Axes.LeftY, deadzoneVertical);
	    }

	    public void AddRightJoystick(Controllers controller, float deadzoneHorizontal = 0, float deadzoneVertical = 0)
	    {
	        horizontal.Add(controller, Axes.RightX, deadzoneHorizontal);
	        vertical.Add(controller, Axes.RightY, deadzoneVertical);
	    }

	    public void Clear()
	    {
	        horizontal.Clear();
	        vertical.Clear();
	    }

	}
}
