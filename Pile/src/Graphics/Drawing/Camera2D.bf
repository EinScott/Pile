using System;

namespace Pile
{
	public class Camera2D
	{
	    Matrix4x4 matrix;
	    bool dirty = true;

	    public Matrix4x4 Matrix
	    {
	        get
	        {
	            if (dirty) UpdateMatrix();
	            return matrix;
	        }
	    }

	    private UPoint2 viewport;
	    public UPoint2 Viewport
	    {
	        get => viewport;
	        set
	        {
	            viewport = value;
	            dirty = true;
	        }
	    }

	    private Vector2 remainder;
	    private Point2 point;
	    public Vector2 Position
	    {
	        get => point + remainder;
	        set
	        {
	            point = Point2((int)Math.Round(value.X), (int)Math.Round(value.Y));
	            remainder = value - point;
	            dirty = true;
	        }
	    }

	    public float Xf
	    {
	        get => point.X + remainder.X;
	        set
	        {
	            point.X = (int)Math.Round(value);
	            remainder.X = value - point.X;
	            dirty = true;
	        }
	    }

	    public float Yf
	    {
	        get => point.Y + remainder.Y;
	        set
	        {
	            point.Y = (int)Math.Round(value);
	            remainder.Y = value - point.Y;
	            dirty = true;
	        }
	    }

	    public Point2 Point
	    {
	        get => point;
	        set
	        {
	            point = value;
	            remainder = Vector2.Zero;
	            dirty = true;
	        }
	    }

	    public int X
	    {
	        get => point.X;
	        set
	        {
	            point.X = value;
	            remainder.X = 0;
	            dirty = true;
	        }
	    }

	    public int Y
	    {
	        get => point.Y;
	        set
	        {
	            point.Y = value;
	            remainder.Y = 0;
	            dirty = true;
	        }
	    }

	    public int Top => point.Y - (int)(viewport.Y / 2);
	    public int Bottom => point.Y + (int)(viewport.Y / 2);
	    public int Left => point.X - (int)(viewport.X / 2);
	    public int Right => point.X + (int)(viewport.X / 2);

	    private void UpdateMatrix()
	    {
	        // Create orthographics matrix centered on the position point
	        matrix = Matrix4x4.FromOrthographic(
	            Left,
	            Right,
	            Top,
	            Bottom,
	            0, float.MaxValue);
	    }

		public static explicit operator Matrix4x4(Camera2D cam) => cam.Matrix;
	}
}
