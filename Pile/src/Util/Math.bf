namespace System
{
	extension Math
	{
		public const float HalfPI_f = (.)(Math.PI_d / 2);
		public const double HalfPI_d = Math.PI_d / 2;
		public const float TAU_f = (.)(Math.PI_d * 2);
		public const double TAU_d = Math.PI_d * 2;

		public const float DegToRad_f = (.)((Math.PI_d * 2) / 360d);
		public const double DegToRad_d = (Math.PI_d * 2) / 360d;
		public const float RadToDeg_f = (.)(360d / (Math.PI_d * 2));
		public const double RadToDeg_d = 360d / (Math.PI_d * 2);

		public static T Approach<T>(T from, T target, T amount) where bool : operator T > T, operator T < T where T : operator T - T, operator T + T
		{
		    if (from > target)
		        return Math.Max(from - amount, target);
		    else
		        return Math.Min(from + amount, target);
		}

		public static float YoYo(float value)
		{
		    if (value <= 0.5f)
		        return value * 2;
		    else
		        return 1 - ((value - 0.5f) * 2);
		}

		public static double YoYo(double value)
		{
		    if (value <= 0.5f)
		        return value * 2;
		    else
		        return 1 - ((value - 0.5f) * 2);
		}

		public static float Map(float val, float min, float max, float newMin = 0, float newMax = 1)
		{
		    return ((val - min) / (max - min)) * (newMax - newMin) + newMin;
		}

		public static float SineMap(float counter, float newMin, float newMax)
		{
		    return Map((float)Math.Sin(counter), 0, 1, newMin, newMax);
		}

		public static float ClampedMap(float val, float min, float max, float newMin = 0, float newMax = 1)
		{
		    return Clamp((val - min) / (max - min), 0, 1) * (newMax - newMin) + newMin;
		}

		public static double Map(double val, double min, double max, double newMin = 0, double newMax = 1)
		{
		    return ((val - min) / (max - min)) * (newMax - newMin) + newMin;
		}

		public static double SineMap(double counter, double newMin, double newMax)
		{
		    return Map((float)Math.Sin(counter), 0, 1, newMin, newMax);
		}

		public static double ClampedMap(double val, double min, double max, double newMin = 0, double newMax = 1)
		{
		    return Clamp((val - min) / (max - min), 0, 1) * (newMax - newMin) + newMin;
		}

		public static float AngleApproach(float val, float target, float maxMove)
		{
		    var diff = AngleDiff(val, target);
		    if (Math.Abs(diff) < maxMove)
		        return target;
		    return val + Clamp(diff, -maxMove, maxMove);
		}

		public static float AngleLerp(float startAngle, float endAngle, float percent)
		{
		    return startAngle + AngleDiff(startAngle, endAngle) * percent;
		}

		public static float AngleDiff(float radiansA, float radiansB)
		{
		    return ((radiansB - radiansA - PI_f) % TAU_f + TAU_f) % TAU_f - PI_f;
		}

		public static double AngleApproach(double val, double target, double maxMove)
		{
		    var diff = AngleDiff(val, target);
		    if (Math.Abs(diff) < maxMove)
		        return target;
		    return val + Clamp(diff, -maxMove, maxMove);
		}

		public static double AngleLerp(double startAngle, double endAngle, double percent)
		{
		    return startAngle + AngleDiff(startAngle, endAngle) * percent;
		}

		public static double AngleDiff(double radiansA, double radiansB)
		{
		    return ((radiansB - radiansA - PI_d) % TAU_d + TAU_d) % TAU_d - PI_d;
		}

		public static float Snap(float value, float snapTo)
		{
		    return Math.Round(value / snapTo) * snapTo;
		}

		public static double Snap(double value, double snapTo)
		{
		    return Math.Round(value / snapTo) * snapTo;
		}

		[Inline]
		public static bool IsBitSet(uint8 b, int pos)
		{
		    return (b & (1 << pos)) != 0;
		}

		[Inline]
		public static bool IsBitSet(int16 b, int pos)
		{
		    return (b & (1 << pos)) != 0;
		}

		[Inline]
		public static bool IsBitSet(int32 b, int pos)
		{
		    return (b & (1 << pos)) != 0;
		}

		[Inline]
		public static bool IsBitSet(int64 b, int pos)
		{
		    return (b & (1 << pos)) != 0;
		}

		// todo: on Triangulate, i don't like the List and Vector2 dependancy. Should move it somewhere else.
		/*public static void Triangulate(List<Vector2> points, List<int32> populate)
		{
		    float Area()
		    {
		        var area = 0f;

		        for (int p = points.Count - 1, int q = 0; q < points.Count; p = q++)
		        {
		            var pval = points[p];
		            var qval = points[q];

		            area += pval.X * qval.Y - qval.X * pval.Y;
		        }

		        return area * 0.5f;
		    }

		    bool Snip(int u, int v, int w, int n, Span<int32> list)
		    {
		        var a = points[list[u]];
		        var b = points[list[v]];
		        var c = points[list[w]];

		        if (float.Epsilon > (((b.X - a.X) * (c.Y - a.Y)) - ((b.Y - a.Y) * (c.X - a.X))))
		            return false;

		        for (int p = 0; p < n; p++)
		        {
		            if ((p == u) || (p == v) || (p == w))
		                continue;

		            if (InsideTriangle(a, b, c, points[list[p]]))
		                return false;
		        }

		        return true;
		    }

		    if (points.Count < 3)
		        return;

		    int32[] list = new int32[points.Count];

		    if (Area() > 0)
		    {
		        for (int32 v = 0; v < points.Count; v++)
		            list[v] = v;
		    }
		    else
		    {
		        for (int32 v = 0; v < points.Count; v++)
		            list[v] = ((.)points.Count - 1) - v;
		    }

		    var nv = points.Count;
		    var count = 2 * nv;

		    for (int v = nv - 1; nv > 2;)
		    {
		        if ((count--) <= 0)
		            return;

		        var u = v;
		        if (nv <= u)
		            u = 0;
		        v = u + 1;
		        if (nv <= v)
		            v = 0;
		        var w = v + 1;
		        if (nv <= w)
		            w = 0;

		        if (Snip(u, v, w, nv, list))
		        {
		            populate.Add(list[u]);
		            populate.Add(list[v]);
		            populate.Add(list[w]);

		            for (int s = v, int t = v + 1; t < nv; s++, t++)
		                list[s] = list[t];

		            nv--;
		            count = 2 * nv;
		        }
		    }
			delete list;

			populate.Reverse();
		}*/
	}
}
