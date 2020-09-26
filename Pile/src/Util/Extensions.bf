using System;

namespace Pile
{
	static
	{
		public static void Format(this String format, params Object[] insertions)
		{
			var findString = scope String(4); // No one will probably ever exceed two digit numbers here... hopefully
			var insertBuf = scope String();

			for (int32 i = 0; i < insertions.Count; i++)
			{
				// FindString construction for i
				findString.Append('{');
				i.ToString(findString);
				findString.Append('}');

				// InsertBuf construction for insert
				insertions[i].ToString(insertBuf);

				// Look for findString
				format.Replace(findString, insertBuf);

				findString.Clear();
				insertBuf.Clear();
			}
		}
	}

	using JSON_Beef.Types;

	// JSONDocument really should be a static thing, but for some reason it isn't
	static class JSONParser
	{
		public static JSONDocument parse = new JSONDocument() ~ delete _;

		public static bool IsValidJson(String json) => parse.IsValidJson(json);

		public static Result<JSONObject, JSON_ERRORS> ParseObject(String json) => parse.ParseObject(json);
		public static Result<void, JSON_ERRORS> ParseObject(String json, ref JSONObject object) => parse.ParseObject(json, ref object);

		public static Result<JSONArray, JSON_ERRORS> ParseArray(String json) => parse.ParseArray(json);
		public static Result<void, JSON_ERRORS> ParseArray(String json, ref JSONArray array) => parse.ParseArray(json, ref array);

		public static JSON_DOCUMENT_TYPE GetJsonType(String json) => parse.GetJsonType(json);
	}
}

using Pile;

namespace System
{
	public extension Math
	{
		public const float HalfPI = (.)(Math.PI_d / 2);
		public const float TAU = (.)(Math.PI_d * 2);

		public const float DegToRad = (.)((Math.PI_d * 2) / 360d);
		public const float RadToDeg = (.)(360d / (Math.PI_d * 2));

		public static float Approach(float from, float target, float amount)
		{
		    if (from > target)
		        return Math.Max(from - amount, target);
		    else
		        return Math.Min(from + amount, target);
		}

		public static Vector2 Approach(Vector2 from, Vector2 target, float amount)
		{
		    if (from == target)
		        return target;
		    else
		    {
		        var diff = target - from;
		        if (diff.Length <= amount * amount)
		            return target;
		        else
		            return from + diff.Normalized() * amount;
		    }
		}

		public static float Lerp(float a, float b, float percent)
		{
		    return (a + (b - a) * percent);
		}

		public static int Clamp(int value, int min, int max)
		{
		    return Math.Min(Math.Max(value, min), max);
		}

		public static float Clamp(float value, float min, float max)
		{
		    return Math.Min(Math.Max(value, min), max);
		}

		public static float YoYo(float value)
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

		public static float Angle(Vector2 vec)
		{
		    return Math.Atan2(vec.Y, vec.X);
		}

		public static float Angle(Vector2 from, Vector2 to)
		{
		    return Math.Atan2(to.Y - from.Y, to.X - from.X);
		}

		public static Vector2 AngleToVector(float angle, float length = 1)
		{
		    return Vector2(Math.Cos(angle) * length, Math.Sin(angle) * length);
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
		    return ((radiansB - radiansA - PI_f) % TAU + TAU) % TAU - PI_f;
		}

		public static float Snap(float value, float snapTo)
		{
		    return Math.Round(value / snapTo) * snapTo;
		}
	}

	namespace IO
	{
		public extension Path
		{
			public static bool SamePath(StringView filePathA, StringView filePathB)
			{
				if (filePathA.Length != filePathB.Length) return false;

				bool matches = true;
				char8* a = filePathA.Ptr;
				char8* b = filePathB.Ptr;

				while (a != filePathA.EndPtr)
				{
					if (*a != *b && !(*a == Path.DirectorySeparatorChar && *b == Path.AltDirectorySeparatorChar || *a == Path.AltDirectorySeparatorChar && *b == Path.DirectorySeparatorChar))
						matches = false;
					a++;
					b++;
				}

				return matches;
			}

			public static void InternalCombineViews(String target, params StringView[] components)
			{
				for (var component in components)
				{
					if ((target.Length > 0) && (!target.EndsWith("\\")) && (!target.EndsWith("/")))
						target.Append(Path.DirectorySeparatorChar);
					target.Append(component);
				}
			}
		}
	}
}
