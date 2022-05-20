using System;

namespace Pile
{
	class Camera3D
	{
		Matrix4x4 combined;
		Matrix4x4 combinedInverse;
		protected Matrix4x4 projection;
		protected Matrix4x4 view;
		protected bool viewDirty = true;
		protected bool projectionDirty = true;
		protected bool lookDirty = true;

		[Inline]
		void RefreshMatrices()
		{
			if (projectionDirty)
				UpdateProjectionMatrix();
			if (viewDirty)
				UpdateView();
			if (viewDirty || projectionDirty)
			{
				viewDirty = false;
				projectionDirty = false;
				UpdateCombinedMatrix();
			}
		}

		public Matrix4x4 CombinedMatrix
		{
		    get
		    {
				RefreshMatrices();
		        return combined;
		    }
		}

		public Matrix4x4 CombinedInverseMatrix
		{
		    get
		    {
				RefreshMatrices();
		        return combinedInverse;
		    }
		}

		public Matrix4x4 ProjectionMatrix
		{
		    get
		    {
				if (projectionDirty)
				{
					UpdateProjectionMatrix();
					UpdateCombinedMatrix();
					projectionDirty = false;
				}
		        return projection;
		    }
		}

		public Matrix4x4 ViewMatrix
		{
		    get
		    {
		        if (viewDirty)
				{
					UpdateView();
					UpdateCombinedMatrix();
					viewDirty = false;
				}
		        return view;
		    }
		}

		protected UPoint2 viewport;
		public UPoint2 Viewport
		{
		    [Inline]get => viewport;
		    set
		    {
		        viewport = value;
				projectionDirty = true;
		    }
		}

		public enum PerspectiveMode
		{
			Perspective,
			Orthographic
		}

		PerspectiveMode perspective;
		public PerspectiveMode PerspectiveMode
		{
			[Inline]get => perspective;
			set
			{
				perspective = value;
				projectionDirty = true;
			}
		}

		protected float fov = 60f;
		protected float fov_rad = 60f * Math.DegToRad_f;
		/// Field of view. Only affects perspective cameras
		public float FOV
		{
			[Inline]get => fov;
			set
			{
				fov = value;
				fov_rad = fov * Math.DegToRad_f;
				projectionDirty = true;
			}
		}

		protected float nearPlane = 0.1f;
		public float NearPlaneDistance
		{
			[Inline]get => nearPlane;
			set
			{
				nearPlane = value;
				projectionDirty = true;
			}
		}

		protected float farPlane = 100f;
		public float FarPlaneDistance
		{
			[Inline]get => farPlane;
			set
			{
				farPlane = value;
				projectionDirty = true;
			}
		}

		protected Vector3 worldUp;
		public Vector3 WorldUp
		{
			[Inline]get => worldUp;
			set
			{
				worldUp = value;
				viewDirty = true;
			}
		}

		protected Vector3 position;
		public Vector3 Position
		{
		    [Inline]get => position;
		    set
		    {
		        position = value;
		        viewDirty = true;
		    }
		}

		public float X
		{
		    [Inline]get => position.X;
		    set
		    {
		        position.X = value;
		        viewDirty = true;
		    }
		}

		public float Y
		{
		    [Inline]get => position.Y;
		    set
		    {
		        position.Y = value;
		        viewDirty = true;
		    }
		}

		public float Z
		{
		    [Inline]get => position.Z;
		    set
		    {
		        position.Z = value;
		        viewDirty = true;
		    }
		}
		
		protected Vector3 up, right, front;
		[Inline]
		public Vector3 Up => up;
		[Inline]
		public Vector3 Right => right;
		[Inline]
		public Vector3 Front => front;

		protected Vector3 look;
		public float Pitch
		{
			[Inline]get => look.Y;
			set
			{
				look.Y = value;
				lookDirty = viewDirty = true;
			}
		}
		public float Yaw
		{
			[Inline]get => look.X;
			set
			{
				look.X = value;
				lookDirty = viewDirty = true;
			}
		}
		public float Roll
		{
			[Inline]get => look.Z;
			set
			{
				look.Z = value;
				lookDirty = viewDirty = true;
			}
		}

		public this(UPoint2 viewport, Vector3 worldUp = .UnitY)
		{
			this.viewport = viewport;
			this.worldUp = worldUp;
		}

		protected virtual void UpdateView()
		{
			if (lookDirty)
			{
				UpdateLook();
				lookDirty = false;
			}

			UpdateViewMatrix();
		}

		protected virtual void UpdateViewMatrix()
		{
			view = Matrix4x4.CreateLookAt(position, position + front, up);
		}

		protected virtual void UpdateLook()
		{
			// Update look - probably at least slightly wrong?
			look.Y = Math.Min(89.9f, Math.Max(-89.9f, look.Y));

			Vector3 newDir = .(
				Math.Cos(look.X * Math.DegToRad_f) * Math.Cos(look.Y * Math.DegToRad_f),
				Math.Sin(look.Y * Math.DegToRad_f),
				Math.Sin(look.X * Math.DegToRad_f) * Math.Cos(look.Y * Math.DegToRad_f)
				);

			front = newDir.ToNormalized();
			right = Vector3.Cross(front, worldUp).ToNormalized();
			up = Vector3.Cross(right, front).ToNormalized();
		}

		protected virtual void UpdateProjectionMatrix()
		{
			projection = perspective == .Perspective
				? Matrix4x4.CreatePerspectiveFieldOfView(fov_rad, (float)viewport.X / viewport.Y, nearPlane, farPlane)
				: Matrix4x4.CreateOrthographic(viewport.X, viewport.Y, nearPlane, farPlane);
		}

		void UpdateCombinedMatrix()
		{
			combined = view * projection; //projection * view; is the way it should be conventionally..
			combinedInverse = TrySilent!(combined.Invert());
		}

		public Vector3 ScreenToCamera(Vector3 position)
		{
		    return Vector3.Transform(position, CombinedInverseMatrix);
		}

		public Vector3 CameraToScreen(Vector3 position)
		{
		    return Vector3.Transform(position, CombinedMatrix);
		}

		public void Approach(Vector3 position, float ease)
		{
		    Position += (position - Position) * ease;
		}

		public void Approach(Vector3 position, float ease, float maxDistance)
		{
		    Vector3 move = (position - Position) * ease;
		    if (move.LengthSquared > maxDistance * maxDistance)
		        Position += move.ToNormalized() * maxDistance;
		    else
		        Position += move;
		}

		public void MoveRelative(float relFront, float relRight, float relUp, Vector2 relLook)
		{
			look += .(relLook, 0);
			
			position += relFront * front;
			position += relRight * right;
			position += relUp * up;

			lookDirty = viewDirty = true;
		}

		public void LookAt(Vector3 position)
		{
			var position;
			position.ToNormalized();

			look.Y = Math.Asin(position.Y);
			look.X = Math.Atan2(position.X, position.Z);

			lookDirty = viewDirty = true;
		}

		// TODO: look at other cams and correct
		// maybe also additions to 2d one
	}
}
