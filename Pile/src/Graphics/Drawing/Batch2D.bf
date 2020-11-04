using System;
using System.Collections;
using System.Diagnostics;

namespace Pile
{
	public class Batch2D
	{
		// TODO: improve this at some point. not constantly pushing a new mesh onto the graphics card would probably be a good idea

		public static readonly VertexFormat VertexFormat = new VertexFormat(
			VertexAttribute("a_position", .Position, .Float, .Two, false),
			VertexAttribute("a_tex", .TexCoord0, .Float, .Two, false),
			VertexAttribute("a_color", .Color0, .Byte, .Four, true),
			VertexAttribute("a_type", .TexCoord1, .Byte, .Three, true)) ~ delete _;

		[Packed]
		[Ordered]
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

		private struct Batch
		{
			//public int layer; // unused in foster, may use later
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
		public readonly Mesh Mesh ~ delete _;

		readonly String TextureUniformName ~ delete _;
		readonly String MatrixUniformName ~ delete _;

		public Matrix3x2 MatrixStack = Matrix3x2.Identity;
		readonly List<Matrix3x2> matrixStack = new List<Matrix3x2>() ~ delete _;

		Vertex[] vertices = new Vertex[64] ~ delete _;
		uint32[] indices = new uint32[64] ~ delete _;
		RenderPass pass;

		readonly List<Batch> batches = new List<Batch>() ~ delete _;
		Batch currentBatch;
		int currentBatchInsert;

		bool dirty;
		
		public int VertexCount { get; private set; }
		public int IndexCount { get; private set; }
		public int TriangleCount => IndexCount / 3;
		public int BatchCount => batches.Count + (currentBatch.elements > 0 ? 1 : 0);

		public this(Material defaultMaterial, StringView textureUniformName = "u_texture", StringView matrixUniformName = "u_matrix")
		{
			DefaultMaterial = defaultMaterial;

			TextureUniformName = new String(textureUniformName);
			MatrixUniformName = new String(matrixUniformName);

			Mesh = new Mesh();

			Clear();
		}

		public void Clear()
		{
			VertexCount = 0;
			IndexCount = 0;

			currentBatchInsert = 0;
			currentBatch = Batch(0, 0, .Identity, .Normal);
			batches.Clear();
			
			MatrixStack = .Identity;
			matrixStack.Clear();
		}

		public void Render(RenderTarget target)
		{
			let size = target.RenderSize;
			let matrix = Matrix4x4.FromOrthographic(0, size.X, 0, size.Y, 0, 100);
			Render(target, matrix);
		}

		public void Render(RenderTarget target, Color clearColor)
		{
		    Core.Graphics.Clear(target, clearColor);
		    Render(target);
		}

		public void Render(RenderTarget target, Matrix4x4 matrix, Rect? viewport = null, Color? clearColor = null)
		{
			if (clearColor != null)
			    Core.Graphics.Clear(target, clearColor.Value);

			pass = RenderPass(target, Mesh, DefaultMaterial);
			pass.viewport = viewport;

			Debug.Assert(matrixStack.Count <= 0, "Batch.MatrixStack Pushes more than it Pops");

			if (batches.Count > 0 || currentBatch.elements > 0)
			{
			    if (dirty)
			    {
					Mesh.SetVertices(Span<Vertex>(vertices), VertexFormat);
					Mesh.SetIndices(Span<uint32>(indices));

			        dirty = false;
			    }

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
			pass.material[TextureUniformName]?.SetTexture(batch.texture);
			pass.material[MatrixUniformName]?.SetMatrix4x4((Matrix4x4)batch.matrix * matrix);

			pass.meshIndexStart = batch.offset * 3;
			pass.meshIndexCount = batch.elements * 3;

			Core.Graphics.Render(ref pass);
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

		public void Line(Vector2 from, Vector2 to, float thickness, Color color)
		{
			let normal = (to - from).Normalized();
			let perp = Vector2(-normal.Y, normal.X) * thickness * 0.5f;
			Quad(from + perp, from - perp, to - perp, to + perp, color);
		}

		public void Quad(Vector2 v0, Vector2 v1, Vector2 v2, Vector2 v3, Color color)
		{
		    PushQuad();
		    ExpandVertices(VertexCount + 4);

		    // POS
		    Transform(ref vertices[VertexCount + 0].position, v0, MatrixStack);
		    Transform(ref vertices[VertexCount + 1].position, v1, MatrixStack);
		    Transform(ref vertices[VertexCount + 2].position, v2, MatrixStack);
		    Transform(ref vertices[VertexCount + 3].position, v3, MatrixStack);

		    // COL
		    vertices[VertexCount + 0].color = color;
		    vertices[VertexCount + 1].color = color;
		    vertices[VertexCount + 2].color = color;
		    vertices[VertexCount + 3].color = color;

		    // MULT
		    vertices[VertexCount + 0].mult = 0;
		    vertices[VertexCount + 1].mult = 0;
		    vertices[VertexCount + 2].mult = 0;
		    vertices[VertexCount + 3].mult = 0;

		    // WASH
		    vertices[VertexCount + 0].wash = 0;
		    vertices[VertexCount + 1].wash = 0;
		    vertices[VertexCount + 2].wash = 0;
		    vertices[VertexCount + 3].wash = 0;

		    // FILL
		    vertices[VertexCount + 0].fill = 255;
		    vertices[VertexCount + 1].fill = 255;
		    vertices[VertexCount + 2].fill = 255;
		    vertices[VertexCount + 3].fill = 255;

		    VertexCount += 4;
		}

		public void Quad(Vector2 v0, Vector2 v1, Vector2 v2, Vector2 v3, Vector2 t0, Vector2 t1, Vector2 t2, Vector2 t3, Color color, bool washed = false)
		{
		    PushQuad();
		    ExpandVertices(VertexCount + 4);

		    var mult = (uint8)(washed ? 0 : 255);
		    var wash = (uint8)(washed ? 255 : 0);

		    // POS
		    Transform(ref vertices[VertexCount + 0].position, v0, MatrixStack);
		    Transform(ref vertices[VertexCount + 1].position, v1, MatrixStack);
		    Transform(ref vertices[VertexCount + 2].position, v2, MatrixStack);
		    Transform(ref vertices[VertexCount + 3].position, v3, MatrixStack);

		    // TEX
		    vertices[VertexCount + 0].texcoord = t0;
		    vertices[VertexCount + 1].texcoord = t1;
		    vertices[VertexCount + 2].texcoord = t2;
		    vertices[VertexCount + 3].texcoord = t3;

		    if (Core.Graphics.OriginBottomLeft && (currentBatch.texture?.IsFrameBuffer ?? false))
		        VerticalFlip(ref vertices[VertexCount + 0].texcoord, ref vertices[VertexCount + 1].texcoord, ref vertices[VertexCount + 2].texcoord, ref vertices[VertexCount + 3].texcoord);

		    // COL
		    vertices[VertexCount + 0].color = color;
		    vertices[VertexCount + 1].color = color;
		    vertices[VertexCount + 2].color = color;
		    vertices[VertexCount + 3].color = color;

		    // MULT
		    vertices[VertexCount + 0].mult = mult;
		    vertices[VertexCount + 1].mult = mult;
		    vertices[VertexCount + 2].mult = mult;
		    vertices[VertexCount + 3].mult = mult;

		    // WASH
		    vertices[VertexCount + 0].wash = wash;
		    vertices[VertexCount + 1].wash = wash;
		    vertices[VertexCount + 2].wash = wash;
		    vertices[VertexCount + 3].wash = wash;

		    // FILL
		    vertices[VertexCount + 0].fill = 0;
		    vertices[VertexCount + 1].fill = 0;
		    vertices[VertexCount + 2].fill = 0;
		    vertices[VertexCount + 3].fill = 0;

		    VertexCount += 4;
		}

		public void Quad(Vector2 v0, Vector2 v1, Vector2 v2, Vector2 v3, Color c0, Color c1, Color c2, Color c3)
		{
		    PushQuad();
		    ExpandVertices(VertexCount + 4);

		    // POS
		    Transform(ref vertices[VertexCount + 0].position, v0, MatrixStack);
		    Transform(ref vertices[VertexCount + 1].position, v1, MatrixStack);
		    Transform(ref vertices[VertexCount + 2].position, v2, MatrixStack);
		    Transform(ref vertices[VertexCount + 3].position, v3, MatrixStack);

		    // COL
		    vertices[VertexCount + 0].color = c0;
		    vertices[VertexCount + 1].color = c1;
		    vertices[VertexCount + 2].color = c2;
		    vertices[VertexCount + 3].color = c3;

		    // MULT
		    vertices[VertexCount + 0].mult = 0;
		    vertices[VertexCount + 1].mult = 0;
		    vertices[VertexCount + 2].mult = 0;
		    vertices[VertexCount + 3].mult = 0;

		    // WASH
		    vertices[VertexCount + 0].wash = 0;
		    vertices[VertexCount + 1].wash = 0;
		    vertices[VertexCount + 2].wash = 0;
		    vertices[VertexCount + 3].wash = 0;

		    // FILL
		    vertices[VertexCount + 0].fill = 255;
		    vertices[VertexCount + 1].fill = 255;
		    vertices[VertexCount + 2].fill = 255;
		    vertices[VertexCount + 3].fill = 255;

		    VertexCount += 4;
		}

		public void Quad(Vector2 v0, Vector2 v1, Vector2 v2, Vector2 v3, Vector2 t0, Vector2 t1, Vector2 t2, Vector2 t3, Color c0, Color c1, Color c2, Color c3, bool washed = false)
		{
		    PushQuad();
		    ExpandVertices(VertexCount + 4);

		    var mult = (uint8)(washed ? 0 : 255);
		    var wash = (uint8)(washed ? 255 : 0);

		    // POS
		    Transform(ref vertices[VertexCount + 0].position, v0, MatrixStack);
		    Transform(ref vertices[VertexCount + 1].position, v1, MatrixStack);
		    Transform(ref vertices[VertexCount + 2].position, v2, MatrixStack);
		    Transform(ref vertices[VertexCount + 3].position, v3, MatrixStack);

		    // TEX
		    vertices[VertexCount + 0].texcoord = t0;
		    vertices[VertexCount + 1].texcoord = t1;
		    vertices[VertexCount + 2].texcoord = t2;
		    vertices[VertexCount + 3].texcoord = t3;

		    if (Core.Graphics.OriginBottomLeft && (currentBatch.texture?.IsFrameBuffer ?? false))
		        VerticalFlip(ref vertices[VertexCount + 0].texcoord, ref vertices[VertexCount + 1].texcoord, ref vertices[VertexCount + 2].texcoord, ref vertices[VertexCount + 3].texcoord);

		    // COL
		    vertices[VertexCount + 0].color = c0;
		    vertices[VertexCount + 1].color = c1;
		    vertices[VertexCount + 2].color = c2;
		    vertices[VertexCount + 3].color = c3;

		    // MULT
		    vertices[VertexCount + 0].mult = mult;
		    vertices[VertexCount + 1].mult = mult;
		    vertices[VertexCount + 2].mult = mult;
		    vertices[VertexCount + 3].mult = mult;

		    // WASH
		    vertices[VertexCount + 0].wash = wash;
		    vertices[VertexCount + 1].wash = wash;
		    vertices[VertexCount + 2].wash = wash;
		    vertices[VertexCount + 3].wash = wash;

		    // FILL
		    vertices[VertexCount + 0].fill = 0;
		    vertices[VertexCount + 1].fill = 0;
		    vertices[VertexCount + 2].fill = 0;
		    vertices[VertexCount + 3].fill = 0;

		    VertexCount += 4;
		}

		public void Triangle(Vector2 v0, Vector2 v1, Vector2 v2, Color color)
		{
		    PushTriangle();
		    ExpandVertices(VertexCount + 3);

		    // POS
		    Transform(ref vertices[VertexCount + 0].position, v0, MatrixStack);
		    Transform(ref vertices[VertexCount + 1].position, v1, MatrixStack);
		    Transform(ref vertices[VertexCount + 2].position, v2, MatrixStack);

		    // COL
		    vertices[VertexCount + 0].color = color;
		    vertices[VertexCount + 1].color = color;
		    vertices[VertexCount + 2].color = color;

		    // MULT
		    vertices[VertexCount + 0].mult = 0;
		    vertices[VertexCount + 1].mult = 0;
		    vertices[VertexCount + 2].mult = 0;
		    vertices[VertexCount + 3].mult = 0;

		    // WASH
		    vertices[VertexCount + 0].wash = 0;
		    vertices[VertexCount + 1].wash = 0;
		    vertices[VertexCount + 2].wash = 0;
		    vertices[VertexCount + 3].wash = 0;

		    // FILL
		    vertices[VertexCount + 0].fill = 255;
		    vertices[VertexCount + 1].fill = 255;
		    vertices[VertexCount + 2].fill = 255;
		    vertices[VertexCount + 3].fill = 255;

		    VertexCount += 3;
		}

		public void Triangle(Vector2 v0, Vector2 v1, Vector2 v2, Color c0, Color c1, Color c2)
		{
		    PushTriangle();
		    ExpandVertices(VertexCount + 3);

		    // POS
		    Transform(ref vertices[VertexCount + 0].position, v0, MatrixStack);
		    Transform(ref vertices[VertexCount + 1].position, v1, MatrixStack);
		    Transform(ref vertices[VertexCount + 2].position, v2, MatrixStack);

		    // COL
		    vertices[VertexCount + 0].color = c0;
		    vertices[VertexCount + 1].color = c1;
		    vertices[VertexCount + 2].color = c2;

		    // MULT
		    vertices[VertexCount + 0].mult = 0;
		    vertices[VertexCount + 1].mult = 0;
		    vertices[VertexCount + 2].mult = 0;
		    vertices[VertexCount + 3].mult = 0;

		    // WASH
		    vertices[VertexCount + 0].wash = 0;
		    vertices[VertexCount + 1].wash = 0;
		    vertices[VertexCount + 2].wash = 0;
		    vertices[VertexCount + 3].wash = 0;

		    // FILL
		    vertices[VertexCount + 0].fill = 255;
		    vertices[VertexCount + 1].fill = 255;
		    vertices[VertexCount + 2].fill = 255;
		    vertices[VertexCount + 3].fill = 255;

		    VertexCount += 3;
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

		public void RoundedRect(float x, float y, float width, float height, float radius, Color color)
		{
		    RoundedRect(x, y, width, height, radius, radius, radius, radius, color);
		}

		public void RoundedRect(Rect rect, float radius, Color color)
		{
		    RoundedRect(rect.X, rect.Y, rect.Width, rect.Height, radius, radius, radius, radius, color);
		}

		// TODO: This doesnt work
		public void RoundedRect(float x, float y, float width, float height, float r0, float r1, float r2, float r3, Color color)
		{
		    // clamp
		    let vr0 = Math.Min(Math.Min(Math.Max(0, r0), width / 2f), height / 2f);
		    let vr1 = Math.Min(Math.Min(Math.Max(0, r1), width / 2f), height / 2f);
		    let vr2 = Math.Min(Math.Min(Math.Max(0, r2), width / 2f), height / 2f);
		    let vr3 = Math.Min(Math.Min(Math.Max(0, r3), width / 2f), height / 2f);

		    if (vr0 <= 0 && vr1 <= 0 && vr2 <= 0 && vr3 <= 0)
		    {
		        Rect(x, y, width, height, color);
		    }
		    else
		    {
		        // get corners
		        let r0_tl = Vector2(x, y);
		        let r0_tr = r0_tl + Vector2(vr0, 0);
		        let r0_br = r0_tl + Vector2(vr0, vr0);
		        let r0_bl = r0_tl + Vector2(0, vr0);

		        let r1_tl = Vector2(x + width, y) + Vector2(-vr1, 0);
		        let r1_tr = r1_tl + Vector2(vr1, 0);
		        let r1_br = r1_tl + Vector2(vr1, vr1);
		        let r1_bl = r1_tl + Vector2(0, vr1);

		        let r2_tl = Vector2(x + width, y + height) + Vector2(-vr2, -vr2);
		        let r2_tr = r2_tl + Vector2(vr2, 0);
		        let r2_bl = r2_tl + Vector2(0, vr2);
		        let r2_br = r2_tl + Vector2(vr2, vr2);

		        let r3_tl = Vector2(x, y + height) + Vector2(0, -vr3);
		        let r3_tr = r3_tl + Vector2(vr3, 0);
		        let r3_bl = r3_tl + Vector2(0, vr3);
		        let r3_br = r3_tl + Vector2(vr3, vr3);

		        // set tris
		        {
					Resize(ref indices, 30);

		            // top quad
		            {
		                indices[IndexCount + 00] = (.)VertexCount + 00; // r0b
		                indices[IndexCount + 01] = (.)VertexCount + 03; // r1a
		                indices[IndexCount + 02] = (.)VertexCount + 05; // r1d

		                indices[IndexCount + 03] = (.)VertexCount + 00; // r0b
		                indices[IndexCount + 04] = (.)VertexCount + 05; // r1d
		                indices[IndexCount + 05] = (.)VertexCount + 01; // r0c
		            }

		            // left quad
		            {
		                indices[IndexCount + 06] = (.)VertexCount + 02; // r0d
		                indices[IndexCount + 07] = (.)VertexCount + 01; // r0c
		                indices[IndexCount + 08] = (.)VertexCount + 10; // r3b

		                indices[IndexCount + 09] = (.)VertexCount + 02; // r0d
		                indices[IndexCount + 10] = (.)VertexCount + 10; // r3b
		                indices[IndexCount + 11] = (.)VertexCount + 09; // r3a
		            }

		            // right quad
		            {
		                indices[IndexCount + 12] = (.)VertexCount + 05; // r1d
		                indices[IndexCount + 13] = (.)VertexCount + 04; // r1c
		                indices[IndexCount + 14] = (.)VertexCount + 07; // r2b

		                indices[IndexCount + 15] = (.)VertexCount + 05; // r1d
		                indices[IndexCount + 16] = (.)VertexCount + 07; // r2b
		                indices[IndexCount + 17] = (.)VertexCount + 06; // r2a
		            }

		            // bottom quad
		            {
		                indices[IndexCount + 18] = (.)VertexCount + 10; // r3b
		                indices[IndexCount + 19] = (.)VertexCount + 06; // r2a
		                indices[IndexCount + 20] = (.)VertexCount + 08; // r2d

		                indices[IndexCount + 21] = (.)VertexCount + 10; // r3b
		                indices[IndexCount + 22] = (.)VertexCount + 08; // r2d
		                indices[IndexCount + 23] = (.)VertexCount + 11; // r3c
		            }

		            // center quad
		            {
		                indices[IndexCount + 24] = (.)VertexCount + 01; // r0c
		                indices[IndexCount + 25] = (.)VertexCount + 05; // r1d
		                indices[IndexCount + 26] = (.)VertexCount + 06; // r2a

		                indices[IndexCount + 27] = (.)VertexCount + 01; // r0c
		                indices[IndexCount + 28] = (.)VertexCount + 06; // r2a
		                indices[IndexCount + 29] = (.)VertexCount + 10; // r3b
		            }

		            IndexCount += 30;
		            currentBatch.elements += 10;
		            dirty = true;
		        }

		        // set verts
		        {
		            ExpandVertices(VertexCount + 12);

					for (int i = 12; i < VertexCount; i++)
						vertices[i] = Vertex(.Zero, .Zero, color, 0, 0, 255);

		            Transform(ref vertices[VertexCount + 00].position, r0_tr, MatrixStack); // 0
		            Transform(ref vertices[VertexCount + 01].position, r0_br, MatrixStack); // 1
		            Transform(ref vertices[VertexCount + 02].position, r0_bl, MatrixStack); // 2

		            Transform(ref vertices[VertexCount + 03].position, r1_tl, MatrixStack); // 3
		            Transform(ref vertices[VertexCount + 04].position, r1_br, MatrixStack); // 4
		            Transform(ref vertices[VertexCount + 05].position, r1_bl, MatrixStack); // 5

		            Transform(ref vertices[VertexCount + 06].position, r2_tl, MatrixStack); // 6
		            Transform(ref vertices[VertexCount + 07].position, r2_tr, MatrixStack); // 7
		            Transform(ref vertices[VertexCount + 08].position, r2_bl, MatrixStack); // 8

		            Transform(ref vertices[VertexCount + 09].position, r3_tl, MatrixStack); // 9
		            Transform(ref vertices[VertexCount + 10].position, r3_tr, MatrixStack); // 10
		            Transform(ref vertices[VertexCount + 11].position, r3_br, MatrixStack); // 11

		            VertexCount += 12;
		        }

		        // top-left corner
		        if (vr0 > 0)
		            SemiCircle(r0_br, RoundedRectUp, -RoundedRectLeft, vr0, Math.Max(3, (int)(vr0 / 4)), color);
		        else
		            Quad(r0_tl, r0_tr, r0_br, r0_bl, color);

		        // top-right corner
		        if (vr1 > 0)
		            SemiCircle(r1_bl, RoundedRectUp, RoundedRectRight, vr1, Math.Max(3, (int)(vr1 / 4)), color);
		        else
		            Quad(r1_tl, r1_tr, r1_br, r1_bl, color);

		        // bottom-right corner
		        if (vr2 > 0)
		            SemiCircle(r2_tl, RoundedRectRight, RoundedRectDown, vr2, Math.Max(3, (int)(vr2 / 4)), color);
		        else
		            Quad(r2_tl, r2_tr, r2_br, r2_bl, color);

		        // bottom-left corner
		        if (vr3 > 0)
		            SemiCircle(r3_tr, RoundedRectDown, RoundedRectLeft, vr3, Math.Max(3, (int)(vr3 / 4)), color);
		        else
		            Quad(r3_tl, r3_tr, r3_br, r3_bl, color);
		    }
		}

		static readonly float RoundedRectLeft = Math.Atan2(-1, 0);
		static readonly float RoundedRectRight = Math.Atan2(1, 0);
		static readonly float RoundedRectUp = Math.Atan2(0, -1);
		static readonly float RoundedRectDown = Math.Atan2(0, 1);

		public void SemiCircle(Vector2 center, float startRadians, float endRadians, float radius, int steps, Color color)
		{
		    SemiCircle(center, startRadians, endRadians, radius, steps, color, color);
		}

		public void SemiCircle(Vector2 center, float startRadians, float endRadians, float radius, int steps, Color centerColor, Color edgeColor)
		{
		    var last = Math.AngleToVector(startRadians, radius);

		    for (int i = 1; i <= steps; i++)
		    {
		        let next = Math.AngleToVector(startRadians + (endRadians - startRadians) * (i / (float)steps), radius);
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
		    var last = Math.AngleToVector(0, radius);

		    for (int i = 1; i <= steps; i++)
		    {
		        let next = Math.AngleToVector((i / (float)steps) * Math.TAU_f, radius);
		        Triangle(center + last, center + next, center, edgeColor, edgeColor, centerColor);
		        last = next;
		    }
		}

		public void HollowCircle(Vector2 center, float radius, float thickness, int steps, Color color)
		{
		    var last = Math.AngleToVector(0, radius);

		    for (int i = 1; i <= steps; i++)
		    {
		        let next = Math.AngleToVector((i / (float)steps) * Math.TAU_f, radius);
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

		    MatrixStack = Matrix3x2.FromTransform(position, origin, scale, rotation) * MatrixStack;

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

		    MatrixStack = Matrix3x2.FromTransform(position, origin, scale, rotation) * MatrixStack;

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

		    MatrixStack = Matrix3x2.FromTransform(position, origin, scale, rotation) * MatrixStack;

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

		    MatrixStack = Matrix3x2.FromTransform(position, origin, scale, rotation) * MatrixStack;

		    var px0 = -frame.X;
		    var py0 = -frame.Y;
		    var px1 = -frame.X + source.Width;
		    var py1 = -frame.Y + source.Height;

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

		// TODO: text here

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

		void PushTriangle()
		{
			Resize(ref indices, IndexCount + 3);

		    indices[IndexCount + 0] = (.)VertexCount + 0;
		    indices[IndexCount + 1] = (.)VertexCount + 1;
		    indices[IndexCount + 2] = (.)VertexCount + 2;

		    IndexCount += 3;
		    currentBatch.elements++;
		    dirty = true;
		}

		void PushQuad()
		{
		    int index = IndexCount;
		    int vert = VertexCount;

			Resize(ref indices, index + 6);

		    indices[index + 0] = (.)vert + 0;
		    indices[index + 1] = (.)vert + 1;
		    indices[index + 2] = (.)vert + 2;
		    indices[index + 3] = (.)vert + 0;
		    indices[index + 4] = (.)vert + 2;
		    indices[index + 5] = (.)vert + 3;

		    IndexCount += 6;
		    currentBatch.elements += 2;
		    dirty = true;
		}

		void ExpandVertices(int index)
		{
			Resize(ref vertices, index);
		}

		void Transform(ref Vector2 to, Vector2 position, Matrix3x2 matrix)
		{
		    to.X = (position.X * matrix.m11) + (position.Y * matrix.m21) + matrix.m31;
		    to.Y = (position.X * matrix.m12) + (position.Y * matrix.m22) + matrix.m32;
		}

		void VerticalFlip(ref Vector2 uv0, ref Vector2 uv1, ref Vector2 uv2, ref Vector2 uv3)
		{
		    uv0.Y = 1 - uv0.Y;
		    uv1.Y = 1 - uv1.Y;
		    uv2.Y = 1 - uv2.Y;
		    uv3.Y = 1 - uv3.Y;
		}

		void Resize<T>(ref T[] array, int requiredSize)
		{
			// Get required size
			var currSize = array.Count;
			while (requiredSize >= currSize) // This may be a stupid way of computing the required size
				currSize *= 2;

			let newArray = new T[currSize];
			Array.Copy(array, newArray, array.Count);

			// Let's call this reallocating with extra steps
			delete array;
			array = newArray;
		}
	}
}
