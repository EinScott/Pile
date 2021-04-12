using System;
using System.Collections;
using System.Diagnostics;
using System.Text;

namespace Pile
{
	class Batch2D : BufferedMesh<Vertex>
	{
		public static readonly VertexFormat BatchVertexFormat = new VertexFormat(
			VertexAttribute("a_position", .Position, .Float, .Two, false),
			VertexAttribute("a_tex", .TexCoord0, .Float, .Two, false),
			VertexAttribute("a_color", .Color0, .Byte, .Four, true),
			VertexAttribute("a_type", .TexCoord1, .Byte, .Three, true)) ~ delete _;

		[Packed]
		[CRepr]
		public struct Vertex
		{
			public Vector2 position;
			public Vector2 texcoord;
			public Color color;

			public uint8 mult;
			public uint8 wash;
			public uint8 fill;

			public this(Vector2 position, Vector2 texcoord, Color color, uint8 mult, uint8 wash, uint8 fill)
			{
				this.position = position;
				this.texcoord = texcoord;
				this.color = color;

				this.mult = mult;
				this.wash = wash;
				this.fill = fill;
			}
		}

		struct Batch
		{
			//public int layer; // TODO: implement, look at currentBatchInsert
			public Material material;
			public BlendMode blendMode;
			public Matrix3x2 matrix;
			public Texture texture;
			public Rect? scissor;

			public uint offset;
			public uint elements;

			public this(uint offset, uint elements, Matrix3x2 matrix, BlendMode blendMode, Texture texture = null, Material material = null)
			{
				this.offset = offset;
				this.elements = elements;

				this.matrix = matrix;
				this.blendMode = blendMode;
				this.scissor = null;

				this.material = material;
				this.texture = texture;
			}
		}

		public readonly Material DefaultMaterial;

		readonly String TextureUniformName ~ delete _;
		readonly String MatrixUniformName ~ delete _;
		int textureUniformIndex;
		int matrixUniformIndex;

		public Matrix3x2 MatrixStack = Matrix3x2.Identity;
		readonly List<Matrix3x2> matrixStack = new List<Matrix3x2>() ~ delete _;

		RenderPass pass;

		readonly List<Batch> batches = new List<Batch>() ~ delete _;
		Batch currentBatch;
		int currentBatchInsert;
		
		public uint BatchCount => (.)batches.Count + (currentBatch.elements > 0 ? 1 : 0);

		public this(Material defaultMaterial, StringView textureUniformName = "u_texture", StringView matrixUniformName = "u_matrix") : base(BatchVertexFormat)
		{
			DefaultMaterial = defaultMaterial;

			TextureUniformName = new String(textureUniformName);
			MatrixUniformName = new String(matrixUniformName);

			// todo: should find an optimisation that works the same for all materials! also see renderBatch() below
			// Optimization for default shader
			textureUniformIndex = defaultMaterial.IndexOf(TextureUniformName);
			matrixUniformIndex = defaultMaterial.IndexOf(MatrixUniformName);

			Clear();
		}

		public new void Clear()
		{
			base.Clear();

			currentBatchInsert = 0;
			currentBatch = Batch(0, 0, .Identity, .Normal);
			batches.Clear();
			
			MatrixStack = .Identity;
			matrixStack.Clear();
		}

		public void Render(IRenderTarget target)
		{
			let size = target.RenderSize;
			let matrix = Matrix4x4.CreateOrthographicOffCenter(0, size.X, size.Y, 0, 0, 100);
			Render(target, matrix);
		}

		public void Render(IRenderTarget target, Color clearColor)
		{
		    Graphics.Clear(target, clearColor);
		    Render(target);
		}

		public void Render(IRenderTarget target, Matrix4x4 matrix, Rect? viewport = null, Color? clearColor = null)
		{
			if (clearColor != null)
			    Graphics.Clear(target, clearColor.Value);

			pass = RenderPass(target, UnderlyingMesh, DefaultMaterial);
			pass.viewport = viewport;

			Debug.Assert(matrixStack.Count <= 0, "Batch.MatrixStack Pushes more than it Pops");

			if (batches.Count > 0 || currentBatch.elements > 0)
			{
			    ApplyBuffers();

			    // Render batches
			    for (int i = 0; i < batches.Count; i++)
			    {
			        // Remaining elements in the current batch
			        if (currentBatchInsert == i && currentBatch.elements > 0)
			            RenderBatch(currentBatch, matrix);

			        // Render the batch
			        RenderBatch(batches[i], matrix);
			    }

			    // Remaining elements in the current batch
			    if (currentBatchInsert == batches.Count && currentBatch.elements > 0)
			        RenderBatch(currentBatch, matrix);
			}
		}

		private void RenderBatch(Batch batch, Matrix4x4 matrix)
		{
			pass.scissor = batch.scissor;
			pass.blendMode = batch.blendMode;

			// Render the Mesh
			// Note we apply the texture and matrix based on the current batch
			// If the user set these on the Material themselves, they will be overwritten here

			pass.material = batch.material ?? DefaultMaterial;
			if (batch.material == DefaultMaterial)
			{
				pass.material[textureUniformIndex].SetTexture(batch.texture);
				pass.material[matrixUniformIndex].SetMatrix4x4((Matrix4x4)batch.matrix * matrix);
			}
			else
			{
				pass.material[TextureUniformName].SetTexture(batch.texture);
				pass.material[MatrixUniformName].SetMatrix4x4((Matrix4x4)batch.matrix * matrix);
			}

			pass.meshIndexStart = batch.offset * 3;
			pass.meshIndexCount = batch.elements * 3;

			Graphics.Render(pass);
		}

		// SET BATCH STATE

		public void SetMaterial(Material material)
		{
			if (currentBatch.elements == 0)
			{
				currentBatch.material = material;
			}
			else if (currentBatch.material != material)
			{
				// Since we need to change material, but already batched some things,
				// we need to put it in a new batch

				// Insert current state to save
				batches.Insert(currentBatchInsert, currentBatch);

				// Reset state and change material
				currentBatch.material = material;
				currentBatch.offset += currentBatch.elements;
				currentBatch.elements = 0;
				currentBatchInsert++;
			}
		}

		public void SetBlendMode(BlendMode blendMode)
		{
			if (currentBatch.elements == 0)
			{
				currentBatch.blendMode = blendMode;
			}
			else if (currentBatch.blendMode != blendMode)
			{
				// Insert current state to save
				batches.Insert(currentBatchInsert, currentBatch);

				// Reset state and change material
				currentBatch.blendMode = blendMode;
				currentBatch.offset += currentBatch.elements;
				currentBatch.elements = 0;
				currentBatchInsert++;
			}
		}

		public void SetMatrix(Matrix3x2 matrix)
		{
			if (currentBatch.elements == 0)
			{
				currentBatch.matrix = matrix;
			}
			else if (currentBatch.matrix != matrix)
			{
				// Insert current state to save
				batches.Insert(currentBatchInsert, currentBatch);

				// Reset state and change material
				currentBatch.matrix = matrix;
				currentBatch.offset += currentBatch.elements;
				currentBatch.elements = 0;
				currentBatchInsert++;
			}
		}

		public void SetScissor(Rect? scissor)
		{
			if (currentBatch.elements == 0)
			{
				currentBatch.scissor = scissor;
			}
			else if (currentBatch.scissor != scissor)
			{
				// Insert current state to save
				batches.Insert(currentBatchInsert, currentBatch);

				// Reset state and change material
				currentBatch.scissor = scissor;
				currentBatch.offset += currentBatch.elements;
				currentBatch.elements = 0;
				currentBatchInsert++;
			}
		}

		public void SetTexture(Texture texture)
		{
			if (currentBatch.elements == 0)
			{
				currentBatch.texture = texture;
			}
			else if (currentBatch.texture != texture)
			{
				// Insert current state to save
				batches.Insert(currentBatchInsert, currentBatch);

				// Reset state and change material
				currentBatch.texture = texture;
				currentBatch.offset += currentBatch.elements;
				currentBatch.elements = 0;
				currentBatchInsert++;
			}
		}

		// public void SetLayer(int32 layer)

		public void SetState(Matrix3x2 matrix, BlendMode blendMode, Rect? scissor, Material material = null)
		{
			SetMatrix(matrix);
			SetBlendMode(blendMode);
			SetScissor(scissor);
			SetMaterial(material);
		}

		// MATRIX STACK

		public Matrix3x2 PushMatrix(Matrix3x2 matrix, bool relative = true)
		{
			matrixStack.Add(MatrixStack);

			if (relative)
				MatrixStack = matrix * MatrixStack;
			else
				MatrixStack = matrix;

			return MatrixStack;
		}

		public Matrix3x2 PopMatrix()
		{
			Debug.Assert(matrixStack.Count > 0, "Batch.MatrixStack Pops more than it Pushes");

			if (matrixStack.Count > 0)
				MatrixStack = matrixStack.PopBack();
			else
				MatrixStack = .Identity;

			return MatrixStack;
		}

		// DRAW

		public void Triangle(Vector2 v0, Vector2 v1, Vector2 v2, Color color)
		{
		    let tri = PushTriangle();

			tri[0] = .(Transform(v0, MatrixStack), .Zero, color, 0, 0, 255);
			tri[1] = .(Transform(v1, MatrixStack), .Zero, color, 0, 0, 255);
			tri[2] = .(Transform(v2, MatrixStack), .Zero, color, 0, 0, 255);

			currentBatch.elements++;
		}

		public void Triangle(Vector2 v0, Vector2 v1, Vector2 v2, Color c0, Color c1, Color c2)
		{
		    let tri = PushTriangle();

			tri[0] = .(Transform(v0, MatrixStack), .Zero, c0, 0, 0, 255);
			tri[1] = .(Transform(v1, MatrixStack), .Zero, c1, 0, 0, 255);
			tri[2] = .(Transform(v2, MatrixStack), .Zero, c2, 0, 0, 255);

			currentBatch.elements++;
		}

		public void Quad(Vector2 v0, Vector2 v1, Vector2 v2, Vector2 v3, Color color)
		{
		    let quad = PushQuad();

			quad[0] = .(Transform(v0, MatrixStack), .Zero, color, 0, 0, 255);
			quad[1] = .(Transform(v1, MatrixStack), .Zero, color, 0, 0, 255);
			quad[2] = .(Transform(v2, MatrixStack), .Zero, color, 0, 0, 255);
			quad[3] = .(Transform(v3, MatrixStack), .Zero, color, 0, 0, 255);

			currentBatch.elements += 2;
		}

		public void Quad(Vector2 v0, Vector2 v1, Vector2 v2, Vector2 v3, Vector2 t0, Vector2 t1, Vector2 t2, Vector2 t3, Color color, bool washed = false)
		{
		    let quad = PushQuad();

		    var mult = (uint8)(washed ? 0 : 255);
		    var wash = (uint8)(washed ? 255 : 0);

			quad[0] = .(Transform(v0, MatrixStack), t0, color, mult, wash, 0);
			quad[1] = .(Transform(v1, MatrixStack), t1, color, mult, wash, 0);
			quad[2] = .(Transform(v2, MatrixStack), t2, color, mult, wash, 0);
			quad[3] = .(Transform(v3, MatrixStack), t3, color, mult, wash, 0);

		    if (Graphics.OriginBottomLeft && (currentBatch.texture?.IsFrameBuffer ?? false))
		        FlipUV(ref quad[0].texcoord, ref quad[1].texcoord, ref quad[2].texcoord, ref quad[3].texcoord);

			currentBatch.elements += 2;
		}

		public void Quad(Vector2 v0, Vector2 v1, Vector2 v2, Vector2 v3, Color c0, Color c1, Color c2, Color c3)
		{
		    let quad = PushQuad();

		    quad[0] = .(Transform(v0, MatrixStack), .Zero, c0, 0, 0, 255);
			quad[1] = .(Transform(v1, MatrixStack), .Zero, c1, 0, 0, 255);
			quad[2] = .(Transform(v2, MatrixStack), .Zero, c2, 0, 0, 255);
			quad[3] = .(Transform(v3, MatrixStack), .Zero, c3, 0, 0, 255);

			currentBatch.elements += 2;
		}

		public void Quad(Vector2 v0, Vector2 v1, Vector2 v2, Vector2 v3, Vector2 t0, Vector2 t1, Vector2 t2, Vector2 t3, Color c0, Color c1, Color c2, Color c3, bool washed = false)
		{
		    let quad = PushQuad();

		    var mult = (uint8)(washed ? 0 : 255);
		    var wash = (uint8)(washed ? 255 : 0);

			quad[0] = .(Transform(v0, MatrixStack), t0, c0, mult, wash, 0);
			quad[1] = .(Transform(v1, MatrixStack), t1, c1, mult, wash, 0);
			quad[2] = .(Transform(v2, MatrixStack), t2, c2, mult, wash, 0);
			quad[3] = .(Transform(v3, MatrixStack), t3, c3, mult, wash, 0);

			if (Graphics.OriginBottomLeft && (currentBatch.texture?.IsFrameBuffer ?? false))
				FlipUV(ref quad[0].texcoord, ref quad[1].texcoord, ref quad[2].texcoord, ref quad[3].texcoord);

			currentBatch.elements += 2;
		}

		public void Line(Vector2 from, Vector2 to, float thickness, Color color)
		{
			let normal = (to - from).Normalize();
			let perp = Vector2(-normal.Y, normal.X) * thickness * 0.5f;
			Quad(from + perp, from - perp, to - perp, to + perp, color);
		}

		public void Rect(Rect rect, Color color)
		{
		    Quad(
		        Vector2(rect.X, rect.Y),
		        Vector2(rect.X + rect.Width, rect.Y),
		        Vector2(rect.X + rect.Width, rect.Y + rect.Height),
		        Vector2(rect.X, rect.Y + rect.Height),
		        color);
		}

		public void Rect(Vector2 position, Vector2 size, Color color)
		{
		    Quad(
		        position,
		        position + Vector2(size.X, 0),
		        position + Vector2(size.X, size.Y),
		        position + Vector2(0, size.Y),
		        color);
		}

		public void Rect(float x, float y, float width, float height, Color color)
		{
		    Quad(
		        Vector2(x, y),
		        Vector2(x + width, y),
		        Vector2(x + width, y + height),
		        Vector2(x, y + height), color);
		}

		public void Rect(Rect rect, Color c0, Color c1, Color c2, Color c3)
		{
		    Quad(
		    	Vector2(rect.X, rect.Y),
		        Vector2(rect.X + rect.Width, rect.Y),
		        Vector2(rect.X + rect.Width, rect.Y + rect.Height),
		        Vector2(rect.X, rect.Y + rect.Height),
		        c0, c1, c2, c3);
		}

		public void Rect(Vector2 position, Vector2 size, Color c0, Color c1, Color c2, Color c3)
		{
		    Quad(
		        position,
		        position + Vector2(size.X, 0),
		        position + Vector2(size.X, size.Y),
		        position + Vector2(0, size.Y),
		        c0, c1, c2, c3);
		}

		public void Rect(float x, float y, float width, float height, Color c0, Color c1, Color c2, Color c3)
		{
		    Quad(
		        Vector2(x, y),
		        Vector2(x + width, y),
		        Vector2(x + width, y + height),
		        Vector2(x, y + height),
		        c0, c1, c2, c3);
		}

		public void SemiCircle(Vector2 center, float startRadians, float endRadians, float radius, int steps, Color color)
		{
		    SemiCircle(center, startRadians, endRadians, radius, steps, color, color);
		}

		public void SemiCircle(Vector2 center, float startRadians, float endRadians, float radius, int steps, Color centerColor, Color edgeColor)
		{
		    var last = Vector2.AngleToVector(startRadians, radius);

		    for (int i = 1; i <= steps; i++)
		    {
		        let next = Vector2.AngleToVector(startRadians + (endRadians - startRadians) * (i / (float)steps), radius);
		        Triangle(center + last, center + next, center, edgeColor, edgeColor, centerColor);
		        last = next;
		    }
		}

		public void Circle(Vector2 center, float radius, int steps, Color color)
		{
		    Circle(center, radius, steps, color, color);
		}

		public void Circle(Vector2 center, float radius, int steps, Color centerColor, Color edgeColor)
		{
		    var last = Vector2.AngleToVector(0, radius);

		    for (int i = 1; i <= steps; i++)
		    {
		        let next = Vector2.AngleToVector((i / (float)steps) * Math.TAU_f, radius);
		        Triangle(center + last, center + next, center, edgeColor, edgeColor, centerColor);
		        last = next;
		    }
		}

		public void HollowCircle(Vector2 center, float radius, float thickness, int steps, Color color)
		{
		    var last = Vector2.AngleToVector(0, radius);

		    for (int i = 1; i <= steps; i++)
		    {
		        let next = Vector2.AngleToVector((i / (float)steps) * Math.TAU_f, radius);
		        Line(center + last, center + next, thickness, color);
		        last = next;
		    }
		}

		public void HollowRect(Rect rect, float t, Color color)
		{
		    if (t > 0)
		    {
		        let tx = Math.Min(t, rect.Width / 2f);
		        let ty = Math.Min(t, rect.Height / 2f);

		        Rect(rect.X, rect.Y, rect.Width, ty, color);
		        Rect(rect.X, rect.Bottom - ty, rect.Width, ty, color);
		        Rect(rect.X, rect.Y + ty, tx, rect.Height - ty * 2, color);
		        Rect(rect.Right - tx, rect.Y + ty, tx, rect.Height - ty * 2, color);
		    }
		}

		public void HollowRect(float x, float y, float width, float height, float t, Color color)
		{
		    if (t > 0)
		    {
		        let tx = Math.Min(t, width / 2f);
		        let ty = Math.Min(t, height / 2f);

		        Rect(x, y, width, ty, color);
		        Rect(x, y + height - ty, width, ty, color);
		        Rect(x, y + ty, tx, height - ty * 2, color);
		        Rect(x + width - tx, y + ty, tx, height - ty * 2, color);
		    }
		}

		public void Image(Texture texture,
		    Vector2 pos0, Vector2 pos1, Vector2 pos2, Vector2 pos3,
		    Vector2 uv0, Vector2 uv1, Vector2 uv2, Vector2 uv3,
		    Color col0, Color col1, Color col2, Color col3, bool washed = false)
		{
		    SetTexture(texture);
		    Quad(pos0, pos1, pos2, pos3, uv0, uv1, uv2, uv3, col0, col1, col2, col3, washed);
		}

		public void Image(Texture texture,
		    Vector2 pos0, Vector2 pos1, Vector2 pos2, Vector2 pos3,
		    Vector2 uv0, Vector2 uv1, Vector2 uv2, Vector2 uv3,
		    Color color, bool washed)
		{
		    SetTexture(texture);
		    Quad(pos0, pos1, pos2, pos3, uv0, uv1, uv2, uv3, color, washed);
		}

		public void Image(Texture texture, Color color = .White, bool washed = false)
		{
		    SetTexture(texture);
		    Quad(
		        .Zero,
		        Vector2(texture.Width, 0),
		        Vector2(texture.Width, texture.Height),
		        Vector2(0, texture.Height),
		        Vector2(0, 0),
		        .UnitX,
		        .One,
		        .UnitY,
		        color, washed);
		}

		public void Image(Texture texture, Vector2 position, Color color = .White, bool washed = false)
		{
		    SetTexture(texture);
		    Quad(
		        position,
		        position + Vector2(texture.Width, 0),
		        position + Vector2(texture.Width, texture.Height),
		        position + Vector2(0, texture.Height),
		        .Zero,
		        .UnitX,
		        .One,
		        .UnitY,
		        color, washed);
		}

		public void Image(Texture texture, Vector2 position, Vector2 scale, Vector2 origin, float rotation, Color color = .White, bool washed = false)
		{
		    let was = MatrixStack;

		    MatrixStack = Matrix3x2.CreateTransform(position, origin, scale, rotation) * MatrixStack;

		    SetTexture(texture);
		    Quad(
		        .Zero,
		        Vector2(texture.Width, 0),
		        Vector2(texture.Width, texture.Height),
		        Vector2(0, texture.Height),
		        .Zero,
		        .UnitX,
		        .One,
		        .UnitY,
		        color, washed);

		    MatrixStack = was;
		}

		public void Image(Texture texture, float cx, float cy, float cwidth, float cheight, Vector2 position, Color color = .White, bool washed = false)
		{
		    let tx0 = cx / texture.Width;
		    let ty0 = cy / texture.Height;
		    let tx1 = (cx + cwidth) / texture.Width;
		    let ty1 = (cy + cheight) / texture.Height;

		    SetTexture(texture);
		    Quad(
		        position,
		        position + Vector2(cwidth, 0),
		        position + Vector2(cwidth, cheight),
		        position + Vector2(0, cheight),
		        Vector2(tx0, ty0),
		        Vector2(tx1, ty0),
		        Vector2(tx1, ty1),
		        Vector2(tx0, ty1),
				color, washed);
		}

		public void Image(Texture texture, float cx, float cy, float cwidth, float cheight, Vector2 position, Vector2 scale, Vector2 origin, float rotation, Color color = .White, bool washed = false)
		{
		    let was = MatrixStack;

		    MatrixStack = Matrix3x2.CreateTransform(position, origin, scale, rotation) * MatrixStack;

		    let tx0 = cx / texture.Width;
			let ty0 = cy / texture.Height;
			let tx1 = (cx + cwidth) / texture.Width;
			let ty1 = (cy + cheight) / texture.Height;

		    SetTexture(texture);
		    Quad(
				position,
				position + Vector2(cwidth, 0),
				position + Vector2(cwidth, cheight),
				position + Vector2(0, cheight),
				Vector2(tx0, ty0),
				Vector2(tx1, ty0),
				Vector2(tx1, ty1),
				Vector2(tx0, ty1),
				color, washed);

		    MatrixStack = was;
		}

		public void Image(Subtexture subtex, Color color = .White, bool washed = false)
		{
		    SetTexture(subtex.Texture);
		    Quad(
		        subtex.DrawCoords[0], subtex.DrawCoords[1], subtex.DrawCoords[2], subtex.DrawCoords[3],
		        subtex.TexCoords[0], subtex.TexCoords[1], subtex.TexCoords[2], subtex.TexCoords[3],
		        color, washed);
		}

		public void Image(Subtexture subtex, Vector2 position, Color color = .White, bool washed = false)
		{
		    SetTexture(subtex.Texture);
		    Quad(position + subtex.DrawCoords[0], position + subtex.DrawCoords[1], position + subtex.DrawCoords[2], position + subtex.DrawCoords[3],
		        subtex.TexCoords[0], subtex.TexCoords[1], subtex.TexCoords[2], subtex.TexCoords[3],
		        color, washed);
		}

		public void Image(Subtexture subtex, Vector2 position, Vector2 scale, Vector2 origin, float rotation, Color color = .White, bool washed = false)
		{
		    var was = MatrixStack;

		    MatrixStack = Matrix3x2.CreateTransform(position, origin, scale, rotation) * MatrixStack;

		    SetTexture(subtex.Texture);
		    Quad(
		        subtex.DrawCoords[0], subtex.DrawCoords[1], subtex.DrawCoords[2], subtex.DrawCoords[3],
		        subtex.TexCoords[0], subtex.TexCoords[1], subtex.TexCoords[2], subtex.TexCoords[3],
		        color, washed);

		    MatrixStack = was;
		}

		public void Image(Subtexture subtex, Rect clip, Vector2 position, Vector2 scale, Vector2 origin, float rotation, Color color = .White, bool washed = false)
		{
		    var (source, frame) = subtex.GetClip(clip);
		    var tex = subtex.Texture;
		    var was = MatrixStack;

		    MatrixStack = Matrix3x2.CreateTransform(position, origin, scale, rotation) * MatrixStack;

		    let px0 = -frame.X;
		    let py0 = -frame.Y;
		    let px1 = -frame.X + source.Width;
		    let py1 = -frame.Y + source.Height;

		    var tx0 = 0f;
		    var ty0 = 0f;
		    var tx1 = 0f;
		    var ty1 = 0f;

		    if (tex != null)
		    {
		        tx0 = source.Left / tex.Width;
		        ty0 = source.Top / tex.Height;
		        tx1 = source.Right / tex.Width;
		        ty1 = source.Bottom / tex.Height;
		    }

		    SetTexture(subtex.Texture);
		    Quad(
		        Vector2(px0, py0), Vector2(px1, py0), Vector2(px1, py1), Vector2(px0, py1),
		        Vector2(tx0, ty0), Vector2(tx1, ty0), Vector2(tx1, ty1), Vector2(tx0, ty1),
		        color, washed);

		    MatrixStack = was;
		}

		// Render an UTF8 string
		public void Text(SpriteFont font, StringView text, Color color)
		{
		    var position = Vector2(0, font.Ascent);

		    for (int i = 0; i < text.Length; i++)
		    {
				char32 char = ?;

				// Encoded unicode char
				if (UTF8.GetDecodedLength(text[i]) > 1)
				{
					let res = UTF8.Decode(&text[i], Math.Min(5, text.Length - i));
					
					i += res.length - 1;

					if (res.c == (char32)-1)
						continue; // Invalid

					char = res.c;
				}
				else char = text[i];

		        if (char == '\n')
		        {
		            position.X = 0;
		            position.Y += font.LineHeight;
		            continue;
		        }

		        if (!font.Charset.TryGetValue(char, let ch))
		            continue;

				// Image offset/kerning
		        if (ch.Image != null)
		        {
		            var at = position + ch.Offset;

					// Look ahead
					do
					{
			            if (i < text.Length - 1 && text[i + 1] != '\n')
			            {
							// Look up next char
							char32 nextChar = ?;
	
							// Encoded unicode char
							if (UTF8.GetDecodedLength(text[i + 1]) > 1)
							{
								let res = UTF8.Decode(&text[i + 1], Math.Min(5, text.Length - i));
	
								if (res.c == (char32)-1)
									break;
	
								nextChar = res.c;
							}
							else nextChar = text[i + 1];
	
			                if (ch.Kerning.TryGetValue(nextChar, let kerning))
			                    at.X += kerning;
			            }
					}

					// Render glyph
		            Image(ch.Image, at, color, true);
		        }

		        position.X += ch.Advance;
		    }
		}

		// Render an UTF8 string
		public void Text(SpriteFont font, StringView text, Vector2 position, Color color)
		{
		    PushMatrix(Matrix3x2.CreateTransform(position, .One, 0));
		    Text(font, text, color);
		    PopMatrix();
		}

		// Render an UTF8 string
		public void Text(SpriteFont font, StringView text, Vector2 position, Vector2 scale, Vector2 origin, float rotation, Color color)
		{
		    PushMatrix(Matrix3x2.CreateTransform(position, origin, scale, rotation));
		    Text(font, text, color);
		    PopMatrix();
		}

		public void CheckeredPattern(Rect bounds, float cellWidth, float cellHeight, Color a, Color b)
		{
		    var odd = false;

		    for (float y = bounds.Top; y < bounds.Bottom; y += cellHeight)
		    {
		        var cells = 0;
		        for (float x = bounds.Left; x < bounds.Right; x += cellWidth)
		        {
		            var color = (odd ? a : b);
		            if (color.A > 0)
		                Rect(x, y, Math.Min(bounds.Right - x, cellWidth), Math.Min(bounds.Bottom - y, cellHeight), color);

		            odd = !odd;
		            cells++;
		        }

		        if (cells % 2 == 0)
		            odd = !odd;
		    }
		}

		// UTIL

		[Inline]
		Vector2 Transform(Vector2 position, Matrix3x2 matrix)
		{
			return .(
		    	(position.X * matrix.M11) + (position.Y * matrix.M21) + matrix.M31,
		    	(position.X * matrix.M12) + (position.Y * matrix.M22) + matrix.M32);
		}

		[Inline]
		void FlipUV(ref Vector2 uv0, ref Vector2 uv1, ref Vector2 uv2, ref Vector2 uv3)
		{
		    uv0.Y = 1 - uv0.Y;
		    uv1.Y = 1 - uv1.Y;
		    uv2.Y = 1 - uv2.Y;
		    uv3.Y = 1 - uv3.Y;
		}
	}
}
