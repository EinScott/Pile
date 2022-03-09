using System;

namespace Pile
{
	class Camera2D
	{
		Matrix4x4 matrix;
	    Matrix4x4 inverse;
		bool dirty = true;

		[Inline]
		public Rect CameraRect => .(Vector2.Round(point - (Vector2)viewport / (2*zoom)), Vector2.Round((Vector2)viewport / zoom));

	    public Matrix4x4 Matrix
	    {
	        get
	        {
	            if (dirty) UpdateMatrix();
	            return matrix;
	        }
	    }

		public Matrix4x4 Inverse
		{
		    get
		    {
		        if (dirty) UpdateMatrix();
		        return inverse;
		    }
		}

		float zoom = 1;
		public float Zoom
		{
			[Inline]get => zoom;
			set
			{
				zoom = value;
				dirty = true;
			}
		}

	    UPoint2 viewport;
	    public UPoint2 Viewport
	    {
	        [Inline]get => viewport;
	        set
	        {
	            viewport = value;
	            dirty = true;
	        }
	    }

	    Vector2 remainder;
	    Point2 point;
	    public Vector2 Position
	    {
	        [Inline]get => point + remainder;
	        set
	        {
	            point = Point2((int)Math.Round(value.X), (int)Math.Round(value.Y));
	            remainder = value - point;
	            dirty = true;
	        }
	    }

	    public float Xf
	    {
	        [Inline]get => point.X + remainder.X;
	        set
	        {
	            point.X = (int)Math.Round(value);
	            remainder.X = value - point.X;
	            dirty = true;
	        }
	    }

	    public float Yf
	    {
	        [Inline]get => point.Y + remainder.Y;
	        set
	        {
	            point.Y = (int)Math.Round(value);
	            remainder.Y = value - point.Y;
	            dirty = true;
	        }
	    }

	    public Point2 Point
	    {
	        [Inline]get => point;
	        set
	        {
	            point = value;
	            remainder = Vector2.Zero;
	            dirty = true;
	        }
	    }

	    public int X
	    {
	        [Inline]get => point.X;
	        set
	        {
	            point.X = value;
	            remainder.X = 0;
	            dirty = true;
	        }
	    }

	    public int Y
	    {
	        [Inline]get => point.Y;
	        set
	        {
	            point.Y = value;
	            remainder.Y = 0;
	            dirty = true;
	        }
	    }

	    public int Top => point.Y - (int)(viewport.Y / (2*zoom));
	    public int Bottom => point.Y + (int)(viewport.Y / (2*zoom));
	    public int Left => point.X - (int)(viewport.X / (2*zoom));
	    public int Right => point.X + (int)(viewport.X / (2*zoom));

		public this(UPoint2 viewport)
		{
			this.viewport = viewport;
		}

	    void UpdateMatrix()
	    {
	        // Create orthographics matrix centered on the position point
	        matrix = Matrix4x4.CreateOrthographicOffCenter(
	            Left,
	            Right,
	            Bottom,
	            Top,
	            0, float.MaxValue);

			inverse = TrySilent!(matrix.Invert());
	    }

		public static explicit operator Matrix4x4(Camera2D cam) => cam.Matrix;

		public Vector2 ScreenToCamera(Vector2 position)
		{
		    return Vector2.Transform(position, Inverse);
		}

		public Vector2 CameraToScreen(Vector2 position)
		{
		    return Vector2.Transform(position, Matrix);
		}

		public void Approach(Vector2 position, float ease)
		{
		    Position += (position - Position) * ease;
		}

		public void Approach(Vector2 position, float ease, float maxDistance)
		{
		    Vector2 move = (position - Position) * ease;
		    if (move.LengthSquared > maxDistance * maxDistance)
		        Position += move.ToNormalized() * maxDistance;
		    else
		        Position += move;
		}
	}
}
