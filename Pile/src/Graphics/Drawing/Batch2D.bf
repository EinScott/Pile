using System;
using System.Collections;
using System.Diagnostics;
using System.Text;

using internal Pile;

namespace Pile
{
	[Optimize]
	class Batch2D : BufferedMesh<Vertex>
	{
		public static readonly VertexFormat BatchVertexFormat = new VertexFormat(
			VertexAttribute("a_position", .Position, .Float, .Two, false),
			VertexAttribute("a_tex", .TexCoord0, .Float, .Two, false),
			VertexAttribute("a_color", .Color0, .Byte, .Four, true),
			VertexAttribute("a_type", .TexCoord1, .Byte, .Three, true),
			VertexAttribute("a_texIndex", .TexCoord2, .Float, .One, true)) ~ delete _;

		[Packed]
		[CRepr]
		public struct Vertex
		{
			public Vector2 position;
			public Vector2 texCoord;
			public Color color;

			public uint8 mult;
			public uint8 wash;
			public uint8 fill;

			public float texIndex;

			public this(Vector2 position, Vector2 texCoord, Color color, uint8 mult, uint8 wash, uint8 fill, int texIndex)
			{
				this.position = position;
				this.texCoord = texCoord;
				this.color = color;

				this.mult = mult;
				this.wash = wash;
				this.fill = fill;
				this.texIndex = texIndex;
			}
		}

		struct Batch
		{
			public const int MaxTexCount = 32;

			public int32 layer;
			public Material material;
			public BlendMode blendMode;
			public Matrix3x2 matrix;
			public Texture[MaxTexCount] textures;
			public int currentTextureIndex = 0;
			public int textureCount = 0;
			public Rect? scissor;

			public uint offset;
			public uint elements;

			public this(uint offset, uint elements, Matrix3x2 matrix, BlendMode blendMode, int32 layer = 0, Material material = null)
			{
				this.offset = offset;
				this.elements = elements;

				this.matrix = matrix;
				this.blendMode = blendMode;
				this.scissor = null;

				this.layer = layer;

				this.material = material;

				textures = .();
			}

			public bool UseTex(Texture texture) mut
			{
				for (let i < textureCount)
					if (textures[[Unchecked]i] === texture)
					{
						currentTextureIndex = i;
						return true;
					}

				if (textureCount >= MaxTexCount)
					return false;

				textures[textureCount] = texture;
				currentTextureIndex = textureCount;
				textureCount++;

				return true;
			}
		}

		public readonly Material DefaultMaterial ~ if (OwnsDefaultMaterial) delete _;
		readonly bool OwnsDefaultMaterial;

		readonly String TextureUniformName ~ delete _;
		readonly String MatrixUniformName ~ delete _;

		Material lastMaterial;
		int textureUniformIndex;
		int matrixUniformIndex;

		public Matrix3x2 MatrixStack = Matrix3x2.Identity;
		readonly List<Matrix3x2> matrixStack = new List<Matrix3x2>() ~ delete _;

		RenderPass pass;

		readonly List<Batch> batches = new List<Batch>() ~ delete _;
		Batch currentBatch;
		int currentBatchInsert;
		
		public uint BatchCount => (.)batches.Count + (currentBatch.elements > 0 ? 1 : 0);

		/// Creates a Batch2D with the default shader. Other materials provided are expected to use the default "u_texture" and "u_matrix" uniforms
		public this() : this(new Material(Graphics.GetDefaultBatch2dShader()), true) {}

		public this(Material defaultMaterial, bool ownsDefaultMaterial = false, StringView textureUniformName = "u_texture", StringView matrixUniformName = "u_matrix") : base(BatchVertexFormat)
		{
			DefaultMaterial = defaultMaterial;
			OwnsDefaultMaterial = ownsDefaultMaterial;

			TextureUniformName = new String(textureUniformName);
			MatrixUniformName = new String(matrixUniformName);

			lastMaterial = DefaultMaterial;
			textureUniformIndex = DefaultMaterial.IndexOf(TextureUniformName);
			matrixUniformIndex = DefaultMaterial.IndexOf(MatrixUniformName);

			Runtime.Assert(textureUniformIndex != -1 && matrixUniformIndex != -1, "Given shader must have texture and matrix uniforms with the given names");

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

		public void Render(RenderTarget target)
		{
			let size = target.RenderSize;
			let matrix = Matrix4x4.CreateOrthographicOffCenter(0, size.X, size.Y, 0, 0, 100);
			Render(target, matrix);
		}

		public void Render(RenderTarget target, Color clearColor)
		{
		    Graphics.Clear(target, clearColor);
		    Render(target);
		}

		public void Render(RenderTarget target, Matrix4x4 matrix, Rect? viewport = null, Color? clearColor = null)
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
			if (pass.material !== lastMaterial)
			{
				textureUniformIndex = pass.material.IndexOf(TextureUniformName);
				matrixUniformIndex = pass.material.IndexOf(MatrixUniformName);
				lastMaterial = pass.material;
			}

			let texUniform = ref pass.material[textureUniformIndex];
			for (let i < Batch.MaxTexCount)
				texUniform.SetTexture(batch.textures[[Unchecked]i], i);
			pass.material[matrixUniformIndex].SetMatrix4x4((Matrix4x4)batch.matrix * matrix);

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

				// Reset state and change
				currentBatch.material = material;
				ResetCurrentBatch();
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

				// Reset state and change
				currentBatch.blendMode = blendMode;
				ResetCurrentBatch();
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

				// Reset state and change
				currentBatch.matrix = matrix;
				ResetCurrentBatch();
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

				// Reset state and change
				currentBatch.scissor = scissor;
				ResetCurrentBatch();
			}
		}

		public void SetTexture(Texture texture)
		{
			if (currentBatch.textureCount > 0 && currentBatch.textures[currentBatch.currentTextureIndex] === texture)
				return;
			else if (currentBatch.textureCount > 0 && currentBatch.elements == 0)
			{
				// Just one texture was set, but never used yet! Reset it.
				currentBatch.textures[0] = texture;
				currentBatch.currentTextureIndex = 0;
			}
			else if (!currentBatch.UseTex(texture))
			{
				// Insert current state to save
				batches.Insert(currentBatchInsert, currentBatch);

				// Reset state and change
				currentBatch.textures = .();
				currentBatch.textures[0] = texture;
				currentBatch.currentTextureIndex = 0;
				currentBatch.textureCount = 1;

				ResetCurrentBatch();
			}
		}

		public void SetLayer(int32 layer)
		{
			if (currentBatch.elements == 0)
			{
				currentBatch.layer = layer;
			}
			else if (currentBatch.layer != layer)
			{
				// Insert current state to save
				batches.Insert(currentBatchInsert, currentBatch);

				// Reset state and change
				currentBatch.layer = layer;
				ResetCurrentBatch();

				// Set insert
				currentBatchInsert = -1;
				for (let i < batches.Count)
					if (batches[i].layer > layer)
					{
						currentBatchInsert = i;
						break;
					}

				if (currentBatchInsert == -1)
					currentBatchInsert = batches.Count;
			}
		}

		[Inline]
		void ResetCurrentBatch()
		{
			currentBatch.offset += currentBatch.elements;
			currentBatch.elements = 0;
			currentBatchInsert++;
		}

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

			tri[0] = .(Vector2.Transform(v0, MatrixStack), .Zero, color, 0, 0, 255, currentBatch.currentTextureIndex);
			tri[1] = .(Vector2.Transform(v1, MatrixStack), .Zero, color, 0, 0, 255, currentBatch.currentTextureIndex);
			tri[2] = .(Vector2.Transform(v2, MatrixStack), .Zero, color, 0, 0, 255, currentBatch.currentTextureIndex);

			currentBatch.elements++;
		}

		public void Triangle(Vector2 v0, Vector2 v1, Vector2 v2, Color c0, Color c1, Color c2)
		{
		    let tri = PushTriangle();

			tri[0] = .(Vector2.Transform(v0, MatrixStack), .Zero, c0, 0, 0, 255, currentBatch.currentTextureIndex);
			tri[1] = .(Vector2.Transform(v1, MatrixStack), .Zero, c1, 0, 0, 255, currentBatch.currentTextureIndex);
			tri[2] = .(Vector2.Transform(v2, MatrixStack), .Zero, c2, 0, 0, 255, currentBatch.currentTextureIndex);

			currentBatch.elements++;
		}

		public void Quad(Vector2 v0, Vector2 v1, Vector2 v2, Vector2 v3, Color color)
		{
		    let quad = PushQuad();

			quad[0] = .(Vector2.Transform(v0, MatrixStack), .Zero, color, 0, 0, 255, 0);
			quad[1] = .(Vector2.Transform(v1, MatrixStack), .Zero, color, 0, 0, 255, 0);
			quad[2] = .(Vector2.Transform(v2, MatrixStack), .Zero, color, 0, 0, 255, 0);
			quad[3] = .(Vector2.Transform(v3, MatrixStack), .Zero, color, 0, 0, 255, 0);

			currentBatch.elements += 2;
		}

		public void Quad(Vector2 v0, Vector2 v1, Vector2 v2, Vector2 v3, Vector2 t0, Vector2 t1, Vector2 t2, Vector2 t3, Color color, bool washed = false)
		{
		    let quad = PushQuad();

		    var mult = (uint8)(washed ? 0 : 255);
		    var wash = (uint8)(washed ? 255 : 0);

			quad[0] = .(Vector2.Transform(v0, MatrixStack), t0, color, mult, wash, 0, currentBatch.currentTextureIndex);
			quad[1] = .(Vector2.Transform(v1, MatrixStack), t1, color, mult, wash, 0, currentBatch.currentTextureIndex);
			quad[2] = .(Vector2.Transform(v2, MatrixStack), t2, color, mult, wash, 0, currentBatch.currentTextureIndex);
			quad[3] = .(Vector2.Transform(v3, MatrixStack), t3, color, mult, wash, 0, currentBatch.currentTextureIndex);

		    if (Graphics.OriginBottomLeft && (currentBatch.textures[currentBatch.currentTextureIndex]?.IsFrameBuffer ?? false))
		        FlipUV!(ref quad[0].texCoord, ref quad[1].texCoord, ref quad[2].texCoord, ref quad[3].texCoord);

			currentBatch.elements += 2;
		}

		public void Quad(Vector2 v0, Vector2 v1, Vector2 v2, Vector2 v3, Color c0, Color c1, Color c2, Color c3)
		{
		    let quad = PushQuad();

		    quad[0] = .(Vector2.Transform(v0, MatrixStack), .Zero, c0, 0, 0, 255, 0);
			quad[1] = .(Vector2.Transform(v1, MatrixStack), .Zero, c1, 0, 0, 255, 0);
			quad[2] = .(Vector2.Transform(v2, MatrixStack), .Zero, c2, 0, 0, 255, 0);
			quad[3] = .(Vector2.Transform(v3, MatrixStack), .Zero, c3, 0, 0, 255, 0);

			currentBatch.elements += 2;
		}

		public void Quad(Vector2 v0, Vector2 v1, Vector2 v2, Vector2 v3, Vector2 t0, Vector2 t1, Vector2 t2, Vector2 t3, Color c0, Color c1, Color c2, Color c3, bool washed = false)
		{
		    let quad = PushQuad();

		    var mult = (uint8)(washed ? 0 : 255);
		    var wash = (uint8)(washed ? 255 : 0);

			quad[0] = .(Vector2.Transform(v0, MatrixStack), t0, c0, mult, wash, 0, currentBatch.currentTextureIndex);
			quad[1] = .(Vector2.Transform(v1, MatrixStack), t1, c1, mult, wash, 0, currentBatch.currentTextureIndex);
			quad[2] = .(Vector2.Transform(v2, MatrixStack), t2, c2, mult, wash, 0, currentBatch.currentTextureIndex);
			quad[3] = .(Vector2.Transform(v3, MatrixStack), t3, c3, mult, wash, 0, currentBatch.currentTextureIndex);

			if (Graphics.OriginBottomLeft && (currentBatch.textures[currentBatch.currentTextureIndex]?.IsFrameBuffer ?? false))
				FlipUV!(ref quad[0].texCoord, ref quad[1].texCoord, ref quad[2].texCoord, ref quad[3].texCoord);

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
		    let was = MatrixStack;

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
		    let (source, frame) = subtex.GetClip(clip);
		    let tex = subtex.Texture;
		    let was = MatrixStack;

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
		        tx0 = (float)source.Left / tex.Width;
		        ty0 = (float)source.Top / tex.Height;
		        tx1 = (float)source.Right / tex.Width;
		        ty1 = (float)source.Bottom / tex.Height;
		    }

		    SetTexture(subtex.Texture);
		    Quad(
		        Vector2(px0, py0), Vector2(px1, py0), Vector2(px1, py1), Vector2(px0, py1),
		        Vector2(tx0, ty0), Vector2(tx1, ty0), Vector2(tx1, ty1), Vector2(tx0, ty1),
		        color, washed);

		    MatrixStack = was;
		}

		// Returns char advance
		float ProcessChar(SpriteFont font, StringView text, int index, Vector2 relativePos, char32 char, int trueIndex, Color color, CharModifier.GetFunc getModifier, bool washed)
		{
			SpriteFont.Character ch;
			var char;
			if (!font.Charset.TryGetValue(char, out ch))
			{
				if (!font.Charset.TryGetValue('?', out ch)) // Char in set
					return 0;
				else char = '?';
			}

			// Image offset/kerning
			if (ch.Image != null)
			{
				var at = relativePos + ch.Offset;

				// Look ahead
				do if (index < text.Length - 1 && text[index + 1] != '\n')
		        {
					// Look up next char
					var nextIndex = index + 1;
					let res = text.GetChar32(nextIndex);
					if (res.1 == 0) // .1 is length
						break;

		            if (ch.Kerning.TryGetValue(res.0, let kerning))
		                at.X += kerning;
		        }

				CharModifier modifier = getModifier == null ? .None : getModifier(at, trueIndex, char);
				at += modifier.offset;

				var col = color;
				// The call original color will still act as a sort of mask
				if (color != .White || modifier.color != .White)
					col *= modifier.color;

				// Render glyph
				if (modifier.scale == .One && modifier.rotation == 0)
			    	Image(ch.Image, at, col, washed);
				else
				{
					let origin = Vector2(ch.Image.Width / 2, ch.Image.Height / 2);
					Image(ch.Image, at + origin, modifier.scale, origin, modifier.rotation, col, washed);
				}
			}

			return ch.Advance;
		}

		/// Render an UTF8 string. Returns the absolute position where the text ends.
		public Vector2 Text(SpriteFont font, StringView text, Color color, Vector2 extraAdvance = .Zero, CharModifier.GetFunc getModifier = null, bool washed = true)
		{
		    var relativePos = Vector2(0, font.Ascent);
			var trueIndex = 0;
			var textIndex = 0;

		    for (let char in text.DecodedChars)
		    {
		        if (char == '\n')
		        {
		            relativePos.X = 0;
		            relativePos.Y += font.LineHeight + extraAdvance.Y;

					textIndex = @char.NextIndex;
		            continue;
		        }

		        relativePos.X += ProcessChar(font, text, textIndex, relativePos, char, trueIndex, color, getModifier, washed) + extraAdvance.X;
				trueIndex++;

				textIndex = @char.NextIndex;
		    }

			return Vector2.Transform(relativePos - .(0, font.Ascent), MatrixStack);
		}

		/// Render an UTF8 string. Returns the absolute position where the text ends.
		public Vector2 Text(SpriteFont font, StringView text, Vector2 position, Color color = .White, Vector2 extraAdvance = .Zero, CharModifier.GetFunc getModifier = null)
		{
		    PushMatrix(Matrix3x2.CreateTransform(position, .One, 0));
		    let end = Text(font, text, color, extraAdvance, getModifier);
		    PopMatrix();

			return end;
		}

		/// Render an UTF8 string. Returns the absolute position where the text ends.
		public Vector2 Text(SpriteFont font, StringView text, Vector2 position, Vector2 scale, float rotation = 0, Color color = .White, Vector2 extraAdvance = .Zero, CharModifier.GetFunc getModifier = null)
		{
		    PushMatrix(Matrix3x2.CreateTransform(position, scale, rotation));
		    let end = Text(font, text, color, extraAdvance, getModifier);
		    PopMatrix();

			return end;
		}

		/// Render an UTF8 string. Returns the absolute position where the text ends.
		public Vector2 Text(SpriteFont font, StringView text, Vector2 position, Vector2 scale, Vector2 origin, float rotation, Color color = .White, Vector2 extraAdvance = .Zero, CharModifier.GetFunc getModifier = null, bool washed = true)
		{
		    PushMatrix(Matrix3x2.CreateTransform(position, origin, scale, rotation));
		    let end = Text(font, text, color, extraAdvance, getModifier, washed);
		    PopMatrix();

			return end;
		}

		/// Render an UTF8 string. Positions the text into a box. A max size of 0 or lower means unrestrained. Returns the absolute position where the text ends.
		public Vector2 TextFramed(SpriteFont font, StringView text, Rect fitFrame, Color color, float maxSize = 0, CharModifier.GetFunc getModifier = null, bool washed = true)
		{
			let size = font.SizeOf(text);
			var scale = Math.Min(fitFrame.Width / size.X, fitFrame.Height / size.Y);
			if (maxSize > 0)
				scale = Math.Min(maxSize / font.Size, scale);
			let pos = fitFrame.Position + (fitFrame.Size - size * scale) * 0.5f;

			PushMatrix(Matrix3x2.CreateTransform(pos, .(scale), 0));
			let end = Text(font, text, color, .Zero, getModifier, washed);
			PopMatrix();

			return end;
		}

		struct MixedDrawCmd : this(int insertIndex, Vector2 drawPos, int trueIndex);

		static mixin ParseInsert(StringView text, int i, ref int autoInsertIndex, int insertsCount, out int skipLen)
		{
			skipLen = 0;

			// Check that { also has }
			var j = i + 1;
			for (; j < text.Length; j++)
			{
				if (text[j] == '}')
					break;
				else if (!text[j].IsNumber)
					return .Err(default); // Invalid format
			}

			if (j >= text.Length)
				return .Err(default); // Insert not closed

			// Parse in-between
			var insertIndex = 0;
			if (j - i - 1 == 0)
				insertIndex = autoInsertIndex++;
			else
			{
				let start = i + 1;
				let len = j - i - 1;
				for (let k < len)
				{
					let ch = text[start + k];
					Debug.Assert(ch >= '0' && ch <= '9'); // We should have caught this before

					insertIndex = insertIndex * 10 + ch - '0';
				}
			}

			if (insertIndex >= insertsCount)
				return .Err(default); // not enough inserts given, index out of range

			skipLen = j - i;
			insertIndex
		}

		static mixin HandleBrackets(StringView text, char32 char, ref int i)
		{
			if (char == '}')
			{
				if (i + 1 < text.Length && text[i + 1] == '}')
					i++;
				else return .Err(default); // Invalid formatting
			}

			bool isInsert = false;
			if (char == '{')
			{
				if (i + 1 >= text.Length)
					return .Err(default); // Invalid format

				if (text[i + 1] == '{')
					i++;
				else isInsert = true;
			}

			isInsert
		}

		/// Render an UTF8 string with textures mixed in at {}. Behaves similar to AppendF, {{ and }} prints the actual char instead of insertion.
		/// Textures will be rendered to fit the scale of the text. Returns the absolute position where the text ends.
		public Result<Vector2> TextMixed(SpriteFont font, StringView text, Color textColor, Color insertColor, Vector2 extraAdvance, CharModifier.GetFunc getModifier, bool textWashed = true, bool insertsWashed = false, params TextureView[] inserts)
		{
			let draws = scope List<MixedDrawCmd>((.)(inserts.Count * 1.3f) + 1);

		    var relativePos = Vector2(0, font.Ascent);
			var autoInsertIndex = 0;
			var trueIndex = 0;

		    for (int i = 0; i < text.Length; i++)
		    {
				let res = text.GetChar32(i);
				if (res.1 == 0) // .1 is length
					continue;
				i += (res.1) - 1;
				let char = res.0;

		        if (char == '\n')
		        {
		            relativePos.X = 0;
		            relativePos.Y += font.LineHeight + extraAdvance.Y;
		            continue;
		        }

				let isInsert = HandleBrackets!(text, char, ref i);

				if (!isInsert)
		        	relativePos.X += ProcessChar(font, text, i, relativePos, char, trueIndex, textColor, getModifier, textWashed) + extraAdvance.X;
				else
				{
					let insertIndex = ParseInsert!(text, i, ref autoInsertIndex, inserts.Count, let skipLen);

					// Render insert image
					{
						let pos = relativePos - .(0, font.Ascent);

						// Draw the actual stuff later. Drawing these
						// will probably mean a change of texture, thus
						// another draw call, so do these in bulk
						draws.Add(.(insertIndex, pos, trueIndex));

						let image = ref inserts[insertIndex];
						let scale = font.Height / image.Height;

						relativePos.X += image.Width * scale + extraAdvance.X;
					}

					// Make i skip this section
					i += skipLen;
				}

				trueIndex++;
		    }

			for (let draw in draws)
			{
				let image = ref inserts[draw.insertIndex];
				let was = MatrixStack;

				var pos = draw.drawPos;
				var scale = Vector2(font.Height) / image.Height;
				CharModifier modifier = getModifier == null ? .None : getModifier(pos, draw.trueIndex, (char32)0);

				pos += modifier.offset;

				// We need the unmodified scale to adjust our origin on pos correctly,
				// and this later as the actual scale
				let modScale = scale * modifier.scale;

				var col = insertColor;
				if (insertColor != .White || modifier.color != .White)
					col *= modifier.color;

				let origin = Vector2(image.Width / 2, image.Height / 2);
				MatrixStack = Matrix3x2.CreateTransform(pos + origin * scale, origin, modScale, modifier.rotation) * MatrixStack;

				Image(image.texture, image.DrawCoords[0], image.DrawCoords[1], image.DrawCoords[2], image.DrawCoords[3],
					image.TexCoords[0], image.TexCoords[1], image.TexCoords[2], image.TexCoords[3], insertColor, insertsWashed);

				MatrixStack = was;
			}

			return Vector2.Transform(relativePos - .(0, font.Ascent), MatrixStack);
		}

		[Inline]
		/// Render an UTF8 string with textures mixed in at {}. Behaves similar to AppendF, {{ and }} prints the actual char instead of insertion.
		/// Textures will be rendered to fit the scale of the text. Returns the absolute position where the text ends.
		public Result<Vector2> TextMixed(SpriteFont font, StringView text, Color color, params TextureView[] inserts)
		{
			return TextMixed(font, text, color, color, .Zero, null, true, false, params inserts);
		}

		/// Render an UTF8 string with textures mixed in at {}. Behaves similar to AppendF, {{ and }} prints the actual char instead of insertion.
		/// Textures will be rendered to fit the scale of the text. Returns the absolute position where the text ends.
		public Result<Vector2> TextMixed(SpriteFont font, StringView text, Vector2 position, Color color, params TextureView[] inserts)
		{
		    PushMatrix(Matrix3x2.CreateTransform(position, .One, 0));
		    let end = TextMixed(font, text, color, color, .Zero, null, true, false, params inserts);
		    PopMatrix();

			return end;
		}

		/// Render an UTF8 string with textures mixed in at {}. Behaves similar to AppendF, {{ and }} prints the actual char instead of insertion.
		/// Textures will be rendered to fit the scale of the text. Returns the absolute position where the text ends.
		public Result<Vector2> TextMixed(SpriteFont font, StringView text, Vector2 position, Color color, Vector2 extraAdvance, CharModifier.GetFunc getModifier = null, params TextureView[] inserts)
		{
		    PushMatrix(Matrix3x2.CreateTransform(position, .One, 0));
		    let end = TextMixed(font, text, color, color, extraAdvance, getModifier, true, false, params inserts);
		    PopMatrix();

			return end;
		}

		/// Render an UTF8 string with textures mixed in at {}. Behaves similar to AppendF, {{ and }} prints the actual char instead of insertion.
		/// Textures will be rendered to fit the scale of the text. Returns the absolute position where the text ends.
		public Result<Vector2> TextMixed(SpriteFont font, StringView text, Vector2 position, Color color, Vector2 extraAdvance, CharModifier.GetFunc getModifier = null, bool textWashed = true, bool insertsWashed = false, params TextureView[] inserts)
		{
		    PushMatrix(Matrix3x2.CreateTransform(position, .One, 0));
		    let end = TextMixed(font, text, color, color, extraAdvance, getModifier, textWashed, insertsWashed, params inserts);
		    PopMatrix();

			return end;
		}

		/// Render an UTF8 string with textures mixed in at {}. Behaves similar to AppendF, {{ and }} prints the actual char instead of insertion.
		/// Textures will be rendered to fit the scale of the text. Returns the absolute position where the text ends.
		public Result<Vector2> TextMixed(SpriteFont font, StringView text, Vector2 position, Vector2 scale, Vector2 origin, float rotation, Color textColor, Color insertColor, Vector2 extraAdvance, CharModifier.GetFunc getModifier = null, bool textWashed = true, bool insertsWashed = false, params TextureView[] inserts)
		{
		    PushMatrix(Matrix3x2.CreateTransform(position, origin, scale, rotation));
		    let end = TextMixed(font, text, textColor, insertColor, extraAdvance, getModifier, textWashed, insertsWashed, params inserts);
		    PopMatrix();

			return end;
		}

		/// Render an UTF8 string. Positions the text into a box. A max size of 0 or lower means unrestrained. Returns the absolute position where the text ends.
		public Result<Vector2> TextMixedFramed(SpriteFont font, StringView text, Rect fitFrame, Color textColor, Color textureColor, Vector2 extraAdvance, float maxSize = 0, CharModifier.GetFunc getModifier = null, bool textWashed = true, bool insertsWashed = false, params TextureView[] inserts)
		{
			var size = Vector2(0, font.HeightOf(text));
			// Get Width
			{
				var autoInsertIndex = 0;
				var width = 0f;
				var line = 0f;

				for (int i = 0; i < text.Length; i++)
				{
					// Get char
					let res = text.GetChar32(i);
					if (res.1 == 0) // .1 is length
						continue;
					i += (res.1) - 1;
					let char = res.0;

				    if (char == '\n')
				    {
				        if (line > width)
				            width = line;
				        line = 0;

						// Apply extraAdvance to height
						size.Y += extraAdvance.Y;

				        continue;
				    }

					let isInsert = HandleBrackets!(text, char, ref i);

					if (!isInsert)
					{
						if (!font.Charset.TryGetValue(char, let ch))
						    continue;

						line += ch.Advance + extraAdvance.X;
					}
				    else
					{
						let insertIndex = ParseInsert!(text, i, ref autoInsertIndex, inserts.Count, let skipLen);

						// Width of inserted image
						{
							let image = ref inserts[insertIndex];
							let scale = font.Height / image.Height;

							line += image.Width * scale + extraAdvance.X;
						}

						// Make i skip this section
						i += skipLen;
					}
				}

				size.X = Math.Max(width, line);
			}

			var scale = Math.Min(fitFrame.Width / size.X, fitFrame.Height / size.Y);
			if (maxSize > 0)
				scale = Math.Min(maxSize / font.Size, scale);
			let pos = fitFrame.Position + (fitFrame.Size - size * scale) * 0.5f;

			PushMatrix(Matrix3x2.CreateTransform(pos, .(scale), 0));
			let end = TextMixed(font, text, textColor, textureColor, extraAdvance, getModifier, textWashed, insertsWashed, params inserts);
			PopMatrix();

			return end;
		}

		[Inline]
		/// Render an UTF8 string. Positions the text into a box. A max size of 0 or lower means unrestrained. Returns the absolute position where the text ends.
		public Result<Vector2> TextMixedFramed(SpriteFont font, StringView text, Rect fitFrame, Color color, params TextureView[] inserts)
		{
			return TextMixedFramed(font, text, fitFrame, color, color, .Zero, 0, null, true, false, params inserts);
		}

		[Inline]
		/// Render an UTF8 string. Positions the text into a box. A max size of 0 or lower means unrestrained. Returns the absolute position where the text ends.
		public Result<Vector2> TextMixedFramed(SpriteFont font, StringView text, Rect fitFrame, Color color, float maxSize = 0, CharModifier.GetFunc getModifier = null, params TextureView[] inserts)
		{
			return TextMixedFramed(font, text, fitFrame, color, color, .Zero, maxSize, getModifier, true, false, params inserts);
		}

		[Inline]
		/// Render an UTF8 string. Positions the text into a box. A max size of 0 or lower means unrestrained. Returns the absolute position where the text ends.
		public Result<Vector2> TextMixedFramed(SpriteFont font, StringView text, Rect fitFrame, Color color, Vector2 extraAdvance, float maxSize = 0, CharModifier.GetFunc getModifier = null, params TextureView[] inserts)
		{
			return TextMixedFramed(font, text, fitFrame, color, color, extraAdvance, maxSize, getModifier, true, false, params inserts);
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

		mixin FlipUV(ref Vector2 uv0, ref Vector2 uv1, ref Vector2 uv2, ref Vector2 uv3)
		{
		    uv0.Y = 1 - uv0.Y;
		    uv1.Y = 1 - uv1.Y;
		    uv2.Y = 1 - uv2.Y;
		    uv3.Y = 1 - uv3.Y;
		}
	}
}
