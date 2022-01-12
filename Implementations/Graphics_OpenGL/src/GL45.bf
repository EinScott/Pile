using System;

namespace OpenGL45
{
    static class GL
    {
        // GL_NVX_gpu_memory_info
        public const uint32 GL_GPU_MEMORY_INFO_TOTAL_AVAILABLE_MEMORY_NVX = 0x9048;
        public const uint32 GL_GPU_MEMORY_INFO_CURRENT_AVAILABLE_VIDMEM_NVX = 0x9049;

        public const uint32 GL_FRAMEBUFFER_DEFAULT = 0x8218;
        public const uint32 GL_PRIMITIVE_RESTART_FOR_PATCHES_SUPPORTED = 0x8221;
        public const uint32 GL_LOSE_CONTEXT_ON_RESET = 0x8252;
        public const uint32 GL_UNDEFINED_VERTEX = 0x8260;
        public const uint32 GL_NO_RESET_NOTIFICATION = 0x8261;
        public const uint32 GL_MANUAL_GENERATE_MIPMAP = 0x8294;
        public const uint32 GL_FULL_SUPPORT = 0x82B7;
        public const uint32 GL_CAVEAT_SUPPORT = 0x82B8;
        public const uint32 GL_IMAGE_CLASS_4_X_32 = 0x82B9;
        public const uint32 GL_IMAGE_CLASS_2_X_32 = 0x82BA;
        public const uint32 GL_IMAGE_CLASS_1_X_32 = 0x82BB;
        public const uint32 GL_IMAGE_CLASS_4_X_16 = 0x82BC;
        public const uint32 GL_IMAGE_CLASS_2_X_16 = 0x82BD;
        public const uint32 GL_IMAGE_CLASS_1_X_16 = 0x82BE;
        public const uint32 GL_IMAGE_CLASS_4_X_8 = 0x82BF;
        public const uint32 GL_IMAGE_CLASS_2_X_8 = 0x82C0;
        public const uint32 GL_IMAGE_CLASS_1_X_8 = 0x82C1;
        public const uint32 GL_IMAGE_CLASS_11_11_10 = 0x82C2;
        public const uint32 GL_IMAGE_CLASS_10_10_10_2 = 0x82C3;
        public const uint32 GL_VIEW_CLASS_128_BITS = 0x82C4;
        public const uint32 GL_VIEW_CLASS_96_BITS = 0x82C5;
        public const uint32 GL_VIEW_CLASS_64_BITS = 0x82C6;
        public const uint32 GL_VIEW_CLASS_48_BITS = 0x82C7;
        public const uint32 GL_VIEW_CLASS_32_BITS = 0x82C8;
        public const uint32 GL_VIEW_CLASS_24_BITS = 0x82C9;
        public const uint32 GL_VIEW_CLASS_16_BITS = 0x82CA;
        public const uint32 GL_VIEW_CLASS_8_BITS = 0x82CB;
        public const uint32 GL_VIEW_CLASS_S3TC_DXT1_RGB = 0x82CC;
        public const uint32 GL_VIEW_CLASS_S3TC_DXT1_RGBA = 0x82CD;
        public const uint32 GL_VIEW_CLASS_S3TC_DXT3_RGBA = 0x82CE;
        public const uint32 GL_VIEW_CLASS_S3TC_DXT5_RGBA = 0x82CF;
        public const uint32 GL_VIEW_CLASS_RGTC1_RED = 0x82D0;
        public const uint32 GL_VIEW_CLASS_RGTC2_RG = 0x82D1;
        public const uint32 GL_VIEW_CLASS_BPTC_UNORM = 0x82D2;
        public const uint32 GL_VIEW_CLASS_BPTC_FLOAT = 0x82D3;
        public const uint32 GL_DISPLAY_LIST = 0x82E7;
        public const uint32 GL_NUM_SHADING_LANGUAGE_VERSIONS = 0x82E9;
        public const uint32 GL_CONTEXT_RELEASE_BEHAVIOR = 0x82FB;
        public const uint32 GL_CONTEXT_RELEASE_BEHAVIOR_FLUSH = 0x82FC;
        public const uint32 GL_DRAW_BUFFER0 = 0x8825;
        public const uint32 GL_DRAW_BUFFER1 = 0x8826;
        public const uint32 GL_DRAW_BUFFER2 = 0x8827;
        public const uint32 GL_DRAW_BUFFER3 = 0x8828;
        public const uint32 GL_DRAW_BUFFER4 = 0x8829;
        public const uint32 GL_DRAW_BUFFER5 = 0x882A;
        public const uint32 GL_DRAW_BUFFER6 = 0x882B;
        public const uint32 GL_DRAW_BUFFER7 = 0x882C;
        public const uint32 GL_DRAW_BUFFER8 = 0x882D;
        public const uint32 GL_DRAW_BUFFER9 = 0x882E;
        public const uint32 GL_DRAW_BUFFER10 = 0x882F;
        public const uint32 GL_DRAW_BUFFER11 = 0x8830;
        public const uint32 GL_DRAW_BUFFER12 = 0x8831;
        public const uint32 GL_DRAW_BUFFER13 = 0x8832;
        public const uint32 GL_DRAW_BUFFER14 = 0x8833;
        public const uint32 GL_DRAW_BUFFER15 = 0x8834;
        public const uint32 GL_UNSIGNED_NORMALIZED = 0x8C17;
        public const uint32 GL_RGB565 = 0x8D62;
        public const uint32 GL_TRANSFORM_FEEDBACK_BUFFER_PAUSED = 0x8E23;
        public const uint32 GL_TRANSFORM_FEEDBACK_BUFFER_ACTIVE = 0x8E24;
        public const uint32 GL_QUADS_FOLLOW_PROVOKING_VERTEX_CONVENTION = 0x8E4C;
        public const uint32 GL_ISOLINES = 0x8E7A;
        public const uint32 GL_FRACTIONAL_ODD = 0x8E7B;
        public const uint32 GL_FRACTIONAL_EVEN = 0x8E7C;
        public const uint32 GL_SIGNED_NORMALIZED = 0x8F9C;
        public const uint32 GL_IMAGE_FORMAT_COMPATIBILITY_BY_SIZE = 0x90C8;
        public const uint32 GL_IMAGE_FORMAT_COMPATIBILITY_BY_CLASS = 0x90C9;
        public const uint32 GL_SYNC_FENCE = 0x9116;
        public const uint32 GL_UNSIGNALED = 0x9118;
        public const uint32 GL_SIGNALED = 0x9119;
        public const uint32 GL_UNPACK_COMPRESSED_BLOCK_WIDTH = 0x9127;
        public const uint32 GL_UNPACK_COMPRESSED_BLOCK_HEIGHT = 0x9128;
        public const uint32 GL_UNPACK_COMPRESSED_BLOCK_DEPTH = 0x9129;
        public const uint32 GL_UNPACK_COMPRESSED_BLOCK_SIZE = 0x912A;
        public const uint32 GL_PACK_COMPRESSED_BLOCK_WIDTH = 0x912B;
        public const uint32 GL_PACK_COMPRESSED_BLOCK_HEIGHT = 0x912C;
        public const uint32 GL_PACK_COMPRESSED_BLOCK_DEPTH = 0x912D;
        public const uint32 GL_PACK_COMPRESSED_BLOCK_SIZE = 0x912E;
        public const uint32 GL_QUERY_BUFFER_BINDING = 0x9193;
        public const uint32 GL_ATOMIC_COUNTER_BUFFER_START = 0x92C2;
        public const uint32 GL_ATOMIC_COUNTER_BUFFER_SIZE = 0x92C3;

        [AllowDuplicates]
        public enum CullFaceMode : uint32 {
            case GL_FRONT = 0x0404;
            case GL_BACK = 0x0405;
            case GL_FRONT_AND_BACK = 0x0408;
        }

        [AllowDuplicates]
        public enum AlphaFunction : uint32 {
            case GL_EQUAL = 0x0202;
            case GL_GREATER = 0x0204;
            case GL_LEQUAL = 0x0203;
            case GL_NEVER = 0x0200;
            case GL_GEQUAL = 0x0206;
            case GL_LESS = 0x0201;
            case GL_NOTEQUAL = 0x0205;
            case GL_ALWAYS = 0x0207;
        }

        [AllowDuplicates]
        public enum BlitFramebufferFilter : uint32 {
            case GL_LINEAR = 0x2601;
            case GL_NEAREST = 0x2600;
        }

        [AllowDuplicates]
        public enum PolygonMode : uint32 {
            case GL_POINT = 0x1B00;
            case GL_LINE = 0x1B01;
            case GL_FILL = 0x1B02;
        }

        [AllowDuplicates]
        public enum AtomicCounterBufferPName : uint32 {
            case GL_ATOMIC_COUNTER_BUFFER_REFERENCED_BY_COMPUTE_SHADER = 0x90ED;
            case GL_ATOMIC_COUNTER_BUFFER_REFERENCED_BY_FRAGMENT_SHADER = 0x92CB;
            case GL_ATOMIC_COUNTER_BUFFER_ACTIVE_ATOMIC_COUNTER_INDICES = 0x92C6;
            case GL_ATOMIC_COUNTER_BUFFER_REFERENCED_BY_VERTEX_SHADER = 0x92C7;
            case GL_ATOMIC_COUNTER_BUFFER_REFERENCED_BY_TESS_EVALUATION_SHADER = 0x92C9;
            case GL_ATOMIC_COUNTER_BUFFER_REFERENCED_BY_TESS_CONTROL_SHADER = 0x92C8;
            case GL_ATOMIC_COUNTER_BUFFER_DATA_SIZE = 0x92C4;
            case GL_ATOMIC_COUNTER_BUFFER_BINDING = 0x92C1;
            case GL_ATOMIC_COUNTER_BUFFER_ACTIVE_ATOMIC_COUNTERS = 0x92C5;
            case GL_ATOMIC_COUNTER_BUFFER_REFERENCED_BY_GEOMETRY_SHADER = 0x92CA;
        }

        [AllowDuplicates]
        public enum VertexAttribIType : uint32 {
            case GL_BYTE = 0x1400;
            case GL_INT = 0x1404;
            case GL_UNSIGNED_SHORT = 0x1403;
            case GL_UNSIGNED_BYTE = 0x1401;
            case GL_SHORT = 0x1402;
            case GL_UNSIGNED_INT = 0x1405;
        }

        [AllowDuplicates]
        public enum MapTypeNV : uint32 {
            case GL_FLOAT = 0x1406;
            case GL_DOUBLE = 0x140A;
        }

        [AllowDuplicates]
        public enum TransformFeedbackPName : uint32 {
            case GL_TRANSFORM_FEEDBACK_ACTIVE = 0x8E24;
            case GL_TRANSFORM_FEEDBACK_PAUSED = 0x8E23;
            case GL_TRANSFORM_FEEDBACK_BUFFER_START = 0x8C84;
            case GL_TRANSFORM_FEEDBACK_BUFFER_SIZE = 0x8C85;
            case GL_TRANSFORM_FEEDBACK_BUFFER_BINDING = 0x8C8F;
        }

        [AllowDuplicates]
        public enum GetPointervPName : uint32 {
            case GL_DEBUG_CALLBACK_FUNCTION = 0x8244;
            case GL_DEBUG_CALLBACK_USER_PARAM = 0x8245;
        }

        [AllowDuplicates]
        public enum ReplacementCodeTypeSUN : uint32 {
            case GL_UNSIGNED_SHORT = 0x1403;
            case GL_UNSIGNED_BYTE = 0x1401;
            case GL_UNSIGNED_INT = 0x1405;
        }

        [AllowDuplicates]
        public enum TextureEnvMode : uint32 {
            case GL_BLEND = 0x0BE2;
        }

        [AllowDuplicates]
        public enum PathColorFormat : uint32 {
            case GL_RGB = 0x1907;
            case GL_ALPHA = 0x1906;
            case GL_RGBA = 0x1908;
            case GL_NONE = 0;
        }

        [AllowDuplicates]
        public enum ColorTableTargetSGI : uint32 {
            case GL_POST_COLOR_MATRIX_COLOR_TABLE = 0x80D2;
            case GL_PROXY_COLOR_TABLE = 0x80D3;
            case GL_COLOR_TABLE = 0x80D0;
            case GL_PROXY_POST_CONVOLUTION_COLOR_TABLE = 0x80D4;
            case GL_PROXY_POST_COLOR_MATRIX_COLOR_TABLE = 0x80D5;
            case GL_POST_CONVOLUTION_COLOR_TABLE = 0x80D1;
        }

        [AllowDuplicates]
        public enum BufferPNameARB : uint32 {
            case GL_BUFFER_MAPPED = 0x88BC;
            case GL_BUFFER_STORAGE_FLAGS = 0x8220;
            case GL_BUFFER_SIZE = 0x8764;
            case GL_BUFFER_USAGE = 0x8765;
            case GL_BUFFER_MAP_OFFSET = 0x9121;
            case GL_BUFFER_IMMUTABLE_STORAGE = 0x821F;
            case GL_BUFFER_MAP_LENGTH = 0x9120;
            case GL_BUFFER_ACCESS = 0x88BB;
            case GL_BUFFER_ACCESS_FLAGS = 0x911F;
        }

        [AllowDuplicates]
        public enum ConvolutionTargetEXT : uint32 {
            case GL_CONVOLUTION_2D = 0x8011;
            case GL_CONVOLUTION_1D = 0x8010;
        }

        [AllowDuplicates]
        public enum HintMode : uint32 {
            case GL_FASTEST = 0x1101;
            case GL_DONT_CARE = 0x1100;
            case GL_NICEST = 0x1102;
        }

        [AllowDuplicates]
        public enum TextureParameterName : uint32 {
            case GL_TEXTURE_SAMPLES = 0x9106;
            case GL_TEXTURE_HEIGHT = 0x1001;
            case GL_TEXTURE_MAX_LOD = 0x813B;
            case GL_TEXTURE_COMPARE_FUNC = 0x884D;
            case GL_TEXTURE_MIN_FILTER = 0x2801;
            case GL_TEXTURE_BLUE_SIZE = 0x805E;
            case GL_TEXTURE_SWIZZLE_RGBA = 0x8E46;
            case GL_TEXTURE_SWIZZLE_R = 0x8E42;
            case GL_TEXTURE_WIDTH = 0x1000;
            case GL_TEXTURE_GREEN_SIZE = 0x805D;
            case GL_TEXTURE_MIN_LOD = 0x813A;
            case GL_TEXTURE_COMPARE_MODE = 0x884C;
            case GL_TEXTURE_WRAP_R = 0x8072;
            case GL_TEXTURE_MAG_FILTER = 0x2800;
            case GL_TEXTURE_WRAP_S = 0x2802;
            case GL_TEXTURE_WRAP_T = 0x2803;
            case GL_TEXTURE_INTERNAL_FORMAT = 0x1003;
            case GL_TEXTURE_RED_SIZE = 0x805C;
            case GL_TEXTURE_MAX_LEVEL = 0x813D;
            case GL_TEXTURE_SWIZZLE_B = 0x8E44;
            case GL_TEXTURE_SWIZZLE_A = 0x8E45;
            case GL_TEXTURE_BASE_LEVEL = 0x813C;
            case GL_DEPTH_STENCIL_TEXTURE_MODE = 0x90EA;
            case GL_TEXTURE_LOD_BIAS = 0x8501;
            case GL_TEXTURE_SWIZZLE_G = 0x8E43;
            case GL_TEXTURE_ALPHA_SIZE = 0x805F;
            case GL_TEXTURE_BORDER_COLOR = 0x1004;
        }

        [AllowDuplicates]
        public enum VertexBufferObjectParameter : uint32 {
            case GL_BUFFER_MAPPED = 0x88BC;
            case GL_BUFFER_STORAGE_FLAGS = 0x8220;
            case GL_BUFFER_SIZE = 0x8764;
            case GL_BUFFER_USAGE = 0x8765;
            case GL_BUFFER_MAP_OFFSET = 0x9121;
            case GL_BUFFER_IMMUTABLE_STORAGE = 0x821F;
            case GL_BUFFER_MAP_LENGTH = 0x9120;
            case GL_BUFFER_ACCESS = 0x88BB;
            case GL_BUFFER_ACCESS_FLAGS = 0x911F;
        }

        [AllowDuplicates]
        public enum BufferPointerNameARB : uint32 {
            case GL_BUFFER_MAP_POINTER = 0x88BD;
        }

        [AllowDuplicates]
        public enum UniformBlockPName : uint32 {
            case GL_UNIFORM_BLOCK_REFERENCED_BY_TESS_EVALUATION_SHADER = 0x84F1;
            case GL_UNIFORM_BLOCK_ACTIVE_UNIFORMS = 0x8A42;
            case GL_UNIFORM_BLOCK_REFERENCED_BY_VERTEX_SHADER = 0x8A44;
            case GL_UNIFORM_BLOCK_REFERENCED_BY_GEOMETRY_SHADER = 0x8A45;
            case GL_UNIFORM_BLOCK_REFERENCED_BY_COMPUTE_SHADER = 0x90EC;
            case GL_UNIFORM_BLOCK_ACTIVE_UNIFORM_INDICES = 0x8A43;
            case GL_UNIFORM_BLOCK_REFERENCED_BY_FRAGMENT_SHADER = 0x8A46;
            case GL_UNIFORM_BLOCK_DATA_SIZE = 0x8A40;
            case GL_UNIFORM_BLOCK_NAME_LENGTH = 0x8A41;
            case GL_UNIFORM_BLOCK_REFERENCED_BY_TESS_CONTROL_SHADER = 0x84F0;
            case GL_UNIFORM_BLOCK_BINDING = 0x8A3F;
        }

        [AllowDuplicates]
        public enum PrimitiveType : uint32 {
            case GL_LINE_LOOP = 0x0002;
            case GL_LINE_STRIP_ADJACENCY = 0x000B;
            case GL_TRIANGLES_ADJACENCY = 0x000C;
            case GL_TRIANGLE_STRIP_ADJACENCY = 0x000D;
            case GL_LINE_STRIP = 0x0003;
            case GL_PATCHES = 0x000E;
            case GL_LINES_ADJACENCY = 0x000A;
            case GL_TRIANGLE_FAN = 0x0006;
            case GL_TRIANGLE_STRIP = 0x0005;
            case GL_POINTS = 0x0000;
            case GL_LINES = 0x0001;
            case GL_TRIANGLES = 0x0004;
        }

        [AllowDuplicates]
        public enum ProgramPropertyARB : uint32 {
            case GL_GEOMETRY_INPUT_TYPE = 0x8917;
            case GL_TESS_CONTROL_OUTPUT_VERTICES = 0x8E75;
            case GL_TRANSFORM_FEEDBACK_VARYINGS = 0x8C83;
            case GL_GEOMETRY_VERTICES_OUT = 0x8916;
            case GL_ACTIVE_ATTRIBUTE_MAX_LENGTH = 0x8B8A;
            case GL_DELETE_STATUS = 0x8B80;
            case GL_PROGRAM_BINARY_LENGTH = 0x8741;
            case GL_ACTIVE_UNIFORMS = 0x8B86;
            case GL_GEOMETRY_SHADER_INVOCATIONS = 0x887F;
            case GL_VALIDATE_STATUS = 0x8B83;
            case GL_ACTIVE_ATTRIBUTES = 0x8B89;
            case GL_ACTIVE_UNIFORM_BLOCK_MAX_NAME_LENGTH = 0x8A35;
            case GL_TRANSFORM_FEEDBACK_VARYING_MAX_LENGTH = 0x8C76;
            case GL_TESS_GEN_POINT_MODE = 0x8E79;
            case GL_ACTIVE_UNIFORM_MAX_LENGTH = 0x8B87;
            case GL_TESS_GEN_VERTEX_ORDER = 0x8E78;
            case GL_INFO_LOG_LENGTH = 0x8B84;
            case GL_TESS_GEN_SPACING = 0x8E77;
            case GL_ACTIVE_UNIFORM_BLOCKS = 0x8A36;
            case GL_COMPUTE_WORK_GROUP_SIZE = 0x8267;
            case GL_GEOMETRY_OUTPUT_TYPE = 0x8918;
            case GL_TRANSFORM_FEEDBACK_BUFFER_MODE = 0x8C7F;
            case GL_LINK_STATUS = 0x8B82;
            case GL_ATTACHED_SHADERS = 0x8B85;
            case GL_TESS_GEN_MODE = 0x8E76;
            case GL_ACTIVE_ATOMIC_COUNTER_BUFFERS = 0x92D9;
        }

        [AllowDuplicates]
        public enum AttribMask : uint32 {
            case GL_COLOR_BUFFER_BIT = 0x00004000;
            case GL_STENCIL_BUFFER_BIT = 0x00000400;
            case GL_DEPTH_BUFFER_BIT = 0x00000100;
        }

        [AllowDuplicates]
        public enum Boolean : uint32 {
            case GL_TRUE = 1;
            case GL_FALSE = 0;
            public static implicit operator Boolean(bool b) {
                return b ? GL_TRUE : GL_FALSE;
            }
        }

        [AllowDuplicates]
        public enum ClearBufferMask : uint32 {
            case GL_COLOR_BUFFER_BIT = 0x00004000;
            case GL_STENCIL_BUFFER_BIT = 0x00000400;
            case GL_DEPTH_BUFFER_BIT = 0x00000100;
        }

        [AllowDuplicates]
        public enum LogicOp : uint32 {
            case GL_XOR = 0x1506;
            case GL_AND_INVERTED = 0x1504;
            case GL_EQUIV = 0x1509;
            case GL_COPY = 0x1503;
            case GL_NAND = 0x150E;
            case GL_SET = 0x150F;
            case GL_CLEAR = 0x1500;
            case GL_OR = 0x1507;
            case GL_OR_REVERSE = 0x150B;
            case GL_COPY_INVERTED = 0x150C;
            case GL_NOR = 0x1508;
            case GL_OR_INVERTED = 0x150D;
            case GL_NOOP = 0x1505;
            case GL_INVERT = 0x150A;
            case GL_AND = 0x1501;
            case GL_AND_REVERSE = 0x1502;
        }

        [AllowDuplicates]
        public enum MeshMode1 : uint32 {
            case GL_POINT = 0x1B00;
            case GL_LINE = 0x1B01;
        }

        [AllowDuplicates]
        public enum Buffer : uint32 {
            case GL_DEPTH = 0x1801;
            case GL_COLOR = 0x1800;
            case GL_STENCIL = 0x1802;
        }

        [AllowDuplicates]
        public enum PathGenMode : uint32 {
            case GL_NONE = 0;
        }

        [AllowDuplicates]
        public enum QueryObjectParameterName : uint32 {
            case GL_QUERY_RESULT_AVAILABLE = 0x8867;
            case GL_QUERY_TARGET = 0x82EA;
            case GL_QUERY_RESULT = 0x8866;
            case GL_QUERY_RESULT_NO_WAIT = 0x9194;
        }

        [AllowDuplicates]
        public enum MeshMode2 : uint32 {
            case GL_POINT = 0x1B00;
            case GL_LINE = 0x1B01;
            case GL_FILL = 0x1B02;
        }

        [AllowDuplicates]
        public enum UniformType : uint32 {
            case GL_SAMPLER_CUBE_MAP_ARRAY_SHADOW = 0x900D;
            case GL_FLOAT = 0x1406;
            case GL_SAMPLER_2D_MULTISAMPLE_ARRAY = 0x910B;
            case GL_UNSIGNED_INT_SAMPLER_2D = 0x8DD2;
            case GL_UNSIGNED_INT_VEC4 = 0x8DC8;
            case GL_UNSIGNED_INT = 0x1405;
            case GL_INT_SAMPLER_1D_ARRAY = 0x8DCE;
            case GL_INT_SAMPLER_2D_ARRAY = 0x8DCF;
            case GL_SAMPLER_2D_RECT_SHADOW = 0x8B64;
            case GL_SAMPLER_2D_ARRAY = 0x8DC1;
            case GL_INT_SAMPLER_3D = 0x8DCB;
            case GL_SAMPLER_1D_ARRAY = 0x8DC0;
            case GL_SAMPLER_2D_SHADOW = 0x8B62;
            case GL_DOUBLE = 0x140A;
            case GL_INT_SAMPLER_CUBE_MAP_ARRAY = 0x900E;
            case GL_INT_SAMPLER_BUFFER = 0x8DD0;
            case GL_FLOAT_MAT3x4 = 0x8B68;
            case GL_UNSIGNED_INT_SAMPLER_1D = 0x8DD1;
            case GL_FLOAT_MAT3x2 = 0x8B67;
            case GL_BOOL_VEC4 = 0x8B59;
            case GL_SAMPLER_3D = 0x8B5F;
            case GL_BOOL_VEC3 = 0x8B58;
            case GL_BOOL_VEC2 = 0x8B57;
            case GL_UNSIGNED_INT_VEC3 = 0x8DC7;
            case GL_UNSIGNED_INT_VEC2 = 0x8DC6;
            case GL_DOUBLE_MAT4 = 0x8F48;
            case GL_SAMPLER_CUBE_SHADOW = 0x8DC5;
            case GL_DOUBLE_MAT3x4 = 0x8F4C;
            case GL_DOUBLE_MAT3x2 = 0x8F4B;
            case GL_SAMPLER_BUFFER = 0x8DC2;
            case GL_INT_SAMPLER_2D = 0x8DCA;
            case GL_SAMPLER_1D_ARRAY_SHADOW = 0x8DC3;
            case GL_UNSIGNED_INT_SAMPLER_2D_MULTISAMPLE_ARRAY = 0x910D;
            case GL_DOUBLE_MAT3 = 0x8F47;
            case GL_DOUBLE_MAT2 = 0x8F46;
            case GL_UNSIGNED_INT_SAMPLER_BUFFER = 0x8DD8;
            case GL_UNSIGNED_INT_SAMPLER_CUBE = 0x8DD4;
            case GL_FLOAT_MAT4 = 0x8B5C;
            case GL_FLOAT_MAT3 = 0x8B5B;
            case GL_FLOAT_MAT2 = 0x8B5A;
            case GL_UNSIGNED_INT_SAMPLER_2D_RECT = 0x8DD5;
            case GL_SAMPLER_2D = 0x8B5E;
            case GL_UNSIGNED_INT_SAMPLER_2D_MULTISAMPLE = 0x910A;
            case GL_SAMPLER_2D_ARRAY_SHADOW = 0x8DC4;
            case GL_INT_SAMPLER_2D_MULTISAMPLE_ARRAY = 0x910C;
            case GL_SAMPLER_CUBE_MAP_ARRAY = 0x900C;
            case GL_UNSIGNED_INT_SAMPLER_2D_ARRAY = 0x8DD7;
            case GL_UNSIGNED_INT_SAMPLER_1D_ARRAY = 0x8DD6;
            case GL_UNSIGNED_INT_SAMPLER_CUBE_MAP_ARRAY = 0x900F;
            case GL_INT_SAMPLER_1D = 0x8DC9;
            case GL_BOOL = 0x8B56;
            case GL_SAMPLER_CUBE = 0x8B60;
            case GL_SAMPLER_1D_SHADOW = 0x8B61;
            case GL_UNSIGNED_INT_SAMPLER_3D = 0x8DD3;
            case GL_FLOAT_MAT4x3 = 0x8B6A;
            case GL_DOUBLE_VEC4 = 0x8FFE;
            case GL_FLOAT_MAT2x3 = 0x8B65;
            case GL_DOUBLE_VEC3 = 0x8FFD;
            case GL_SAMPLER_2D_MULTISAMPLE = 0x9108;
            case GL_FLOAT_MAT2x4 = 0x8B66;
            case GL_FLOAT_MAT4x2 = 0x8B69;
            case GL_DOUBLE_VEC2 = 0x8FFC;
            case GL_INT_SAMPLER_CUBE = 0x8DCC;
            case GL_SAMPLER_2D_RECT = 0x8B63;
            case GL_INT_SAMPLER_2D_RECT = 0x8DCD;
            case GL_DOUBLE_MAT2x4 = 0x8F4A;
            case GL_DOUBLE_MAT4x2 = 0x8F4D;
            case GL_DOUBLE_MAT4x3 = 0x8F4E;
            case GL_INT = 0x1404;
            case GL_SAMPLER_1D = 0x8B5D;
            case GL_DOUBLE_MAT2x3 = 0x8F49;
            case GL_FLOAT_VEC2 = 0x8B50;
            case GL_INT_SAMPLER_2D_MULTISAMPLE = 0x9109;
            case GL_INT_VEC4 = 0x8B55;
            case GL_FLOAT_VEC4 = 0x8B52;
            case GL_INT_VEC2 = 0x8B53;
            case GL_FLOAT_VEC3 = 0x8B51;
            case GL_INT_VEC3 = 0x8B54;
        }

        [AllowDuplicates]
        public enum MemoryBarrierMask : uint32 {
            case GL_QUERY_BUFFER_BARRIER_BIT = 0x00008000;
            case GL_TEXTURE_FETCH_BARRIER_BIT = 0x00000008;
            case GL_TRANSFORM_FEEDBACK_BARRIER_BIT = 0x00000800;
            case GL_TEXTURE_UPDATE_BARRIER_BIT = 0x00000100;
            case GL_ATOMIC_COUNTER_BARRIER_BIT = 0x00001000;
            case GL_PIXEL_BUFFER_BARRIER_BIT = 0x00000080;
            case GL_FRAMEBUFFER_BARRIER_BIT = 0x00000400;
            case GL_SHADER_STORAGE_BARRIER_BIT = 0x00002000;
            case GL_COMMAND_BARRIER_BIT = 0x00000040;
            case GL_VERTEX_ATTRIB_ARRAY_BARRIER_BIT = 0x00000001;
            case GL_UNIFORM_BARRIER_BIT = 0x00000004;
            case GL_CLIENT_MAPPED_BUFFER_BARRIER_BIT = 0x00004000;
            case GL_BUFFER_UPDATE_BARRIER_BIT = 0x00000200;
            case GL_ELEMENT_ARRAY_BARRIER_BIT = 0x00000002;
            case GL_SHADER_IMAGE_ACCESS_BARRIER_BIT = 0x00000020;
            case GL_ALL_BARRIER_BITS = 0xFFFFFFFF;
        }

        [AllowDuplicates]
        public enum FramebufferParameterName : uint32 {
            case GL_FRAMEBUFFER_DEFAULT_WIDTH = 0x9310;
            case GL_FRAMEBUFFER_DEFAULT_HEIGHT = 0x9311;
            case GL_FRAMEBUFFER_DEFAULT_FIXED_SAMPLE_LOCATIONS = 0x9314;
            case GL_FRAMEBUFFER_DEFAULT_LAYERS = 0x9312;
            case GL_FRAMEBUFFER_DEFAULT_SAMPLES = 0x9313;
        }

        [AllowDuplicates]
        public enum VertexAttribEnum : uint32 {
            case GL_VERTEX_ATTRIB_ARRAY_ENABLED = 0x8622;
            case GL_VERTEX_ATTRIB_ARRAY_DIVISOR = 0x88FE;
            case GL_VERTEX_ATTRIB_ARRAY_TYPE = 0x8625;
            case GL_CURRENT_VERTEX_ATTRIB = 0x8626;
            case GL_VERTEX_ATTRIB_ARRAY_INTEGER = 0x88FD;
            case GL_VERTEX_ATTRIB_ARRAY_SIZE = 0x8623;
            case GL_VERTEX_ATTRIB_ARRAY_STRIDE = 0x8624;
            case GL_VERTEX_ATTRIB_ARRAY_NORMALIZED = 0x886A;
            case GL_VERTEX_ATTRIB_ARRAY_BUFFER_BINDING = 0x889F;
        }

        [AllowDuplicates]
        public enum ColorTableTarget : uint32 {
            case GL_POST_COLOR_MATRIX_COLOR_TABLE = 0x80D2;
            case GL_PROXY_COLOR_TABLE = 0x80D3;
            case GL_COLOR_TABLE = 0x80D0;
            case GL_PROXY_POST_CONVOLUTION_COLOR_TABLE = 0x80D4;
            case GL_PROXY_POST_COLOR_MATRIX_COLOR_TABLE = 0x80D5;
            case GL_POST_CONVOLUTION_COLOR_TABLE = 0x80D1;
        }

        [AllowDuplicates]
        public enum MinmaxTarget : uint32 {
            case GL_MINMAX = 0x802E;
        }

        [AllowDuplicates]
        public enum FramebufferAttachment : uint32 {
            case GL_COLOR_ATTACHMENT15 = 0x8CEF;
            case GL_COLOR_ATTACHMENT14 = 0x8CEE;
            case GL_COLOR_ATTACHMENT17 = 0x8CF1;
            case GL_COLOR_ATTACHMENT16 = 0x8CF0;
            case GL_COLOR_ATTACHMENT0 = 0x8CE0;
            case GL_COLOR_ATTACHMENT11 = 0x8CEB;
            case GL_COLOR_ATTACHMENT10 = 0x8CEA;
            case GL_COLOR_ATTACHMENT13 = 0x8CED;
            case GL_COLOR_ATTACHMENT12 = 0x8CEC;
            case GL_COLOR_ATTACHMENT4 = 0x8CE4;
            case GL_COLOR_ATTACHMENT3 = 0x8CE3;
            case GL_COLOR_ATTACHMENT2 = 0x8CE2;
            case GL_COLOR_ATTACHMENT31 = 0x8CFF;
            case GL_COLOR_ATTACHMENT1 = 0x8CE1;
            case GL_COLOR_ATTACHMENT30 = 0x8CFE;
            case GL_STENCIL_ATTACHMENT = 0x8D20;
            case GL_COLOR_ATTACHMENT8 = 0x8CE8;
            case GL_COLOR_ATTACHMENT7 = 0x8CE7;
            case GL_COLOR_ATTACHMENT6 = 0x8CE6;
            case GL_COLOR_ATTACHMENT5 = 0x8CE5;
            case GL_COLOR_ATTACHMENT29 = 0x8CFD;
            case GL_COLOR_ATTACHMENT26 = 0x8CFA;
            case GL_COLOR_ATTACHMENT25 = 0x8CF9;
            case GL_COLOR_ATTACHMENT28 = 0x8CFC;
            case GL_COLOR_ATTACHMENT27 = 0x8CFB;
            case GL_COLOR_ATTACHMENT22 = 0x8CF6;
            case GL_COLOR_ATTACHMENT21 = 0x8CF5;
            case GL_COLOR_ATTACHMENT24 = 0x8CF8;
            case GL_DEPTH_ATTACHMENT = 0x8D00;
            case GL_COLOR_ATTACHMENT23 = 0x8CF7;
            case GL_COLOR_ATTACHMENT20 = 0x8CF4;
            case GL_COLOR_ATTACHMENT9 = 0x8CE9;
            case GL_COLOR_ATTACHMENT19 = 0x8CF3;
            case GL_COLOR_ATTACHMENT18 = 0x8CF2;
        }

        [AllowDuplicates]
        public enum BlendingFactor : uint32 {
            case GL_SRC_COLOR = 0x0300;
            case GL_ONE_MINUS_SRC1_COLOR = 0x88FA;
            case GL_SRC1_ALPHA = 0x8589;
            case GL_CONSTANT_COLOR = 0x8001;
            case GL_ONE_MINUS_SRC_COLOR = 0x0301;
            case GL_ZERO = 0;
            case GL_ONE = 1;
            case GL_ONE_MINUS_SRC_ALPHA = 0x0303;
            case GL_ONE_MINUS_DST_COLOR = 0x0307;
            case GL_ONE_MINUS_CONSTANT_COLOR = 0x8002;
            case GL_CONSTANT_ALPHA = 0x8003;
            case GL_DST_ALPHA = 0x0304;
            case GL_SRC1_COLOR = 0x88F9;
            case GL_ONE_MINUS_SRC1_ALPHA = 0x88FB;
            case GL_ONE_MINUS_DST_ALPHA = 0x0305;
            case GL_ONE_MINUS_CONSTANT_ALPHA = 0x8004;
            case GL_SRC_ALPHA = 0x0302;
            case GL_DST_COLOR = 0x0306;
            case GL_SRC_ALPHA_SATURATE = 0x0308;
        }

        [AllowDuplicates]
        public enum UseProgramStageMask : uint32 {
            case GL_ALL_SHADER_BITS = 0xFFFFFFFF;
            case GL_TESS_CONTROL_SHADER_BIT = 0x00000008;
            case GL_GEOMETRY_SHADER_BIT = 0x00000004;
            case GL_FRAGMENT_SHADER_BIT = 0x00000002;
            case GL_COMPUTE_SHADER_BIT = 0x00000020;
            case GL_TESS_EVALUATION_SHADER_BIT = 0x00000010;
            case GL_VERTEX_SHADER_BIT = 0x00000001;
        }

        [AllowDuplicates]
        public enum BufferTargetARB : uint32 {
            case GL_UNIFORM_BUFFER = 0x8A11;
            case GL_COPY_WRITE_BUFFER = 0x8F37;
            case GL_QUERY_BUFFER = 0x9192;
            case GL_DISPATCH_INDIRECT_BUFFER = 0x90EE;
            case GL_TRANSFORM_FEEDBACK_BUFFER = 0x8C8E;
            case GL_DRAW_INDIRECT_BUFFER = 0x8F3F;
            case GL_PIXEL_UNPACK_BUFFER = 0x88EC;
            case GL_ELEMENT_ARRAY_BUFFER = 0x8893;
            case GL_PIXEL_PACK_BUFFER = 0x88EB;
            case GL_TEXTURE_BUFFER = 0x8C2A;
            case GL_COPY_READ_BUFFER = 0x8F36;
            case GL_ATOMIC_COUNTER_BUFFER = 0x92C0;
            case GL_ARRAY_BUFFER = 0x8892;
            case GL_SHADER_STORAGE_BUFFER = 0x90D2;
        }

        [AllowDuplicates]
        public enum MinmaxTargetEXT : uint32 {
            case GL_MINMAX = 0x802E;
        }

        [AllowDuplicates]
        public enum PixelStoreParameter : uint32 {
            case GL_PACK_ROW_LENGTH = 0x0D02;
            case GL_UNPACK_LSB_FIRST = 0x0CF1;
            case GL_PACK_SKIP_IMAGES = 0x806B;
            case GL_PACK_IMAGE_HEIGHT = 0x806C;
            case GL_UNPACK_IMAGE_HEIGHT = 0x806E;
            case GL_PACK_SKIP_PIXELS = 0x0D04;
            case GL_UNPACK_SKIP_PIXELS = 0x0CF4;
            case GL_UNPACK_SKIP_ROWS = 0x0CF3;
            case GL_PACK_LSB_FIRST = 0x0D01;
            case GL_UNPACK_SWAP_BYTES = 0x0CF0;
            case GL_PACK_SKIP_ROWS = 0x0D03;
            case GL_PACK_ALIGNMENT = 0x0D05;
            case GL_UNPACK_SKIP_IMAGES = 0x806D;
            case GL_PACK_SWAP_BYTES = 0x0D00;
            case GL_UNPACK_ROW_LENGTH = 0x0CF2;
            case GL_UNPACK_ALIGNMENT = 0x0CF5;
        }

        [AllowDuplicates]
        public enum ContextFlagMask : uint32 {
            case GL_CONTEXT_FLAG_DEBUG_BIT = 0x00000002;
            case GL_CONTEXT_FLAG_FORWARD_COMPATIBLE_BIT = 0x00000001;
            case GL_CONTEXT_FLAG_ROBUST_ACCESS_BIT = 0x00000004;
        }

        [AllowDuplicates]
        public enum WeightPointerTypeARB : uint32 {
            case GL_FLOAT = 0x1406;
            case GL_DOUBLE = 0x140A;
            case GL_BYTE = 0x1400;
            case GL_INT = 0x1404;
            case GL_UNSIGNED_SHORT = 0x1403;
            case GL_UNSIGNED_BYTE = 0x1401;
            case GL_SHORT = 0x1402;
            case GL_UNSIGNED_INT = 0x1405;
        }

        [AllowDuplicates]
        public enum RegisterCombinerPname : uint32 {
            case GL_SRC1_ALPHA = 0x8589;
        }

        [AllowDuplicates]
        public enum ClipControlOrigin : uint32 {
            case GL_UPPER_LEFT = 0x8CA2;
            case GL_LOWER_LEFT = 0x8CA1;
        }

        [AllowDuplicates]
        public enum LightEnvModeSGIX : uint32 {
            case GL_REPLACE = 0x1E01;
        }

        [AllowDuplicates]
        public enum FrontFaceDirection : uint32 {
            case GL_CW = 0x0900;
            case GL_CCW = 0x0901;
        }

        [AllowDuplicates]
        public enum ConditionalRenderMode : uint32 {
            case GL_QUERY_NO_WAIT = 0x8E14;
            case GL_QUERY_BY_REGION_WAIT_INVERTED = 0x8E19;
            case GL_QUERY_BY_REGION_WAIT = 0x8E15;
            case GL_QUERY_BY_REGION_NO_WAIT = 0x8E16;
            case GL_QUERY_WAIT_INVERTED = 0x8E17;
            case GL_QUERY_BY_REGION_NO_WAIT_INVERTED = 0x8E1A;
            case GL_QUERY_WAIT = 0x8E13;
            case GL_QUERY_NO_WAIT_INVERTED = 0x8E18;
        }

        [AllowDuplicates]
        public enum GraphicsResetStatus : uint32 {
            case GL_GUILTY_CONTEXT_RESET = 0x8253;
            case GL_NO_ERROR = 0;
            case GL_INNOCENT_CONTEXT_RESET = 0x8254;
            case GL_UNKNOWN_CONTEXT_RESET = 0x8255;
        }

        [AllowDuplicates]
        public enum FogPointerTypeIBM : uint32 {
            case GL_FLOAT = 0x1406;
            case GL_DOUBLE = 0x140A;
        }

        [AllowDuplicates]
        public enum VertexProvokingMode : uint32 {
            case GL_LAST_VERTEX_CONVENTION = 0x8E4E;
            case GL_FIRST_VERTEX_CONVENTION = 0x8E4D;
        }

        [AllowDuplicates]
        public enum ClampColorTargetARB : uint32 {
            case GL_CLAMP_READ_COLOR = 0x891C;
        }

        [AllowDuplicates]
        public enum DebugSource : uint32 {
            case GL_DEBUG_SOURCE_API = 0x8246;
            case GL_DEBUG_SOURCE_SHADER_COMPILER = 0x8248;
            case GL_DEBUG_SOURCE_OTHER = 0x824B;
            case GL_DEBUG_SOURCE_APPLICATION = 0x824A;
            case GL_DONT_CARE = 0x1100;
            case GL_DEBUG_SOURCE_WINDOW_SYSTEM = 0x8247;
            case GL_DEBUG_SOURCE_THIRD_PARTY = 0x8249;
        }

        [AllowDuplicates]
        public enum GetPName : uint32 {
            case GL_PIXEL_PACK_BUFFER_BINDING = 0x88ED;
            case GL_TRANSFORM_FEEDBACK_BINDING = 0x8E25;
            case GL_VERTEX_BINDING_STRIDE = 0x82D8;
            case GL_MAX_CUBE_MAP_TEXTURE_SIZE = 0x851C;
            case GL_VERTEX_BINDING_DIVISOR = 0x82D6;
            case GL_MIN_FRAGMENT_INTERPOLATION_OFFSET = 0x8E5B;
            case GL_MAX_VERTEX_ATOMIC_COUNTER_BUFFERS = 0x92CC;
            case GL_SCISSOR_TEST = 0x0C11;
            case GL_ARRAY_BUFFER_BINDING = 0x8894;
            case GL_MAX_FRAGMENT_INTERPOLATION_OFFSET = 0x8E5C;
            case GL_LINE_WIDTH_RANGE = 0x0B22;
            case GL_PACK_LSB_FIRST = 0x0D01;
            case GL_MAX_TESS_EVALUATION_OUTPUT_COMPONENTS = 0x8E86;
            case GL_MAX_TESS_CONTROL_IMAGE_UNIFORMS = 0x90CB;
            case GL_TEXTURE_BINDING_2D_MULTISAMPLE_ARRAY = 0x9105;
            case GL_MAX_GEOMETRY_IMAGE_UNIFORMS = 0x90CD;
            case GL_PACK_SWAP_BYTES = 0x0D00;
            case GL_ALIASED_LINE_WIDTH_RANGE = 0x846E;
            case GL_MAX_COMPUTE_WORK_GROUP_COUNT = 0x91BE;
            case GL_RENDERBUFFER_BINDING = 0x8CA7;
            case GL_DOUBLEBUFFER = 0x0C32;
            case GL_MAX_FRAGMENT_ATOMIC_COUNTER_BUFFERS = 0x92D0;
            case GL_POLYGON_OFFSET_LINE = 0x2A02;
            case GL_MAX_IMAGE_UNITS = 0x8F38;
            case GL_LINE_SMOOTH_HINT = 0x0C52;
            case GL_MAX_FRAGMENT_SHADER_STORAGE_BLOCKS = 0x90DA;
            case GL_STENCIL_REF = 0x0B97;
            case GL_PROGRAM_PIPELINE_BINDING = 0x825A;
            case GL_SHADER_COMPILER = 0x8DFA;
            case GL_POINT_SIZE_RANGE = 0x0B12;
            case GL_UNIFORM_BUFFER_BINDING = 0x8A28;
            case GL_NUM_SHADER_BINARY_FORMATS = 0x8DF9;
            case GL_MAX_COMBINED_ATOMIC_COUNTERS = 0x92D7;
            case GL_MAX_DEBUG_LOGGED_MESSAGES = 0x9144;
            case GL_MAX_TESS_CONTROL_UNIFORM_COMPONENTS = 0x8E7F;
            case GL_FRAGMENT_SHADER_DERIVATIVE_HINT = 0x8B8B;
            case GL_SAMPLE_COVERAGE_VALUE = 0x80AA;
            case GL_MAX_FRAGMENT_UNIFORM_VECTORS = 0x8DFD;
            case GL_VIEWPORT_INDEX_PROVOKING_VERTEX = 0x825F;
            case GL_MAX_GEOMETRY_INPUT_COMPONENTS = 0x9123;
            case GL_MAX_VERTEX_UNIFORM_VECTORS = 0x8DFB;
            case GL_MAX_TESS_EVALUATION_ATOMIC_COUNTERS = 0x92D4;
            case GL_POLYGON_MODE = 0x0B40;
            case GL_STENCIL_PASS_DEPTH_PASS = 0x0B96;
            case GL_MAX_PROGRAM_TEXEL_OFFSET = 0x8905;
            case GL_STENCIL_BACK_WRITEMASK = 0x8CA5;
            case GL_MAX_SERVER_WAIT_TIMEOUT = 0x9111;
            case GL_DEPTH_TEST = 0x0B71;
            case GL_MAX_TESS_EVALUATION_INPUT_COMPONENTS = 0x886D;
            case GL_SMOOTH_POINT_SIZE_GRANULARITY = 0x0B13;
            case GL_IMAGE_BINDING_ACCESS = 0x8F3E;
            case GL_SHADER_STORAGE_BUFFER_SIZE = 0x90D5;
            case GL_MIN_MAP_BUFFER_ALIGNMENT = 0x90BC;
            case GL_CULL_FACE = 0x0B44;
            case GL_TRANSFORM_FEEDBACK_BUFFER_SIZE = 0x8C85;
            case GL_MAX_COMPUTE_WORK_GROUP_SIZE = 0x91BF;
            case GL_BLEND_SRC_RGB = 0x80C9;
            case GL_BLEND_EQUATION_ALPHA = 0x883D;
            case GL_MAX_DEBUG_MESSAGE_LENGTH = 0x9143;
            case GL_MAJOR_VERSION = 0x821B;
            case GL_SHADER_STORAGE_BUFFER_BINDING = 0x90D3;
            case GL_MAX_COMBINED_IMAGE_UNIFORMS = 0x90CF;
            case GL_CLIP_ORIGIN = 0x935C;
            case GL_MAX_SAMPLES = 0x8D57;
            case GL_VIEWPORT = 0x0BA2;
            case GL_MAX_COMPUTE_TEXTURE_IMAGE_UNITS = 0x91BC;
            case GL_MAX_TESS_EVALUATION_UNIFORM_BLOCKS = 0x8E8A;
            case GL_POLYGON_OFFSET_FACTOR = 0x8038;
            case GL_RESET_NOTIFICATION_STRATEGY = 0x8256;
            case GL_IMAGE_BINDING_NAME = 0x8F3A;
            case GL_SHADER_BINARY_FORMATS = 0x8DF8;
            case GL_BLEND_COLOR = 0x8005;
            case GL_MAX_DEPTH_TEXTURE_SAMPLES = 0x910F;
            case GL_VERTEX_BINDING_BUFFER = 0x8F4F;
            case GL_STENCIL_VALUE_MASK = 0x0B93;
            case GL_IMAGE_BINDING_LAYER = 0x8F3D;
            case GL_DEPTH_CLEAR_VALUE = 0x0B73;
            case GL_DEPTH_FUNC = 0x0B74;
            case GL_MAX_FRAMEBUFFER_LAYERS = 0x9317;
            case GL_STENCIL_BACK_FAIL = 0x8801;
            case GL_MAX_RENDERBUFFER_SIZE = 0x84E8;
            case GL_MAX_VERTEX_UNIFORM_BLOCKS = 0x8A2B;
            case GL_MAX_COMBINED_IMAGE_UNITS_AND_FRAGMENT_OUTPUTS = 0x8F39;
            case GL_STENCIL_BACK_PASS_DEPTH_PASS = 0x8803;
            case GL_MAX_VERTEX_TEXTURE_IMAGE_UNITS = 0x8B4C;
            case GL_PACK_IMAGE_HEIGHT = 0x806C;
            case GL_UNPACK_IMAGE_HEIGHT = 0x806E;
            case GL_MAX_VERTEX_ATTRIB_BINDINGS = 0x82DA;
            case GL_MAX_SAMPLE_MASK_WORDS = 0x8E59;
            case GL_PACK_SKIP_PIXELS = 0x0D04;
            case GL_STENCIL_BACK_VALUE_MASK = 0x8CA4;
            case GL_MAX_FRAMEBUFFER_SAMPLES = 0x9318;
            case GL_TEXTURE_2D = 0x0DE1;
            case GL_CONTEXT_FLAGS = 0x821E;
            case GL_CLIP_DEPTH_MODE = 0x935D;
            case GL_MAX_COMBINED_TESS_CONTROL_UNIFORM_COMPONENTS = 0x8E1E;
            case GL_UNPACK_ROW_LENGTH = 0x0CF2;
            case GL_STENCIL_BACK_FUNC = 0x8800;
            case GL_MAX_3D_TEXTURE_SIZE = 0x8073;
            case GL_VIEWPORT_SUBPIXEL_BITS = 0x825C;
            case GL_MAX_COMBINED_GEOMETRY_UNIFORM_COMPONENTS = 0x8A32;
            case GL_MAX_TESS_CONTROL_OUTPUT_COMPONENTS = 0x8E83;
            case GL_MAX_COMBINED_FRAGMENT_UNIFORM_COMPONENTS = 0x8A33;
            case GL_SMOOTH_LINE_WIDTH_GRANULARITY = 0x0B23;
            case GL_MAX_TESS_EVALUATION_IMAGE_UNIFORMS = 0x90CC;
            case GL_MAX_VERTEX_ATOMIC_COUNTERS = 0x92D2;
            case GL_MAX_TEXTURE_SIZE = 0x0D33;
            case GL_READ_FRAMEBUFFER_BINDING = 0x8CAA;
            case GL_TEXTURE_1D = 0x0DE0;
            case GL_MAX_VARYING_FLOATS = 0x8B4B;
            case GL_MAX_GEOMETRY_TOTAL_OUTPUT_COMPONENTS = 0x8DE1;
            case GL_MAX_COMBINED_TESS_EVALUATION_UNIFORM_COMPONENTS = 0x8E1F;
            case GL_MAX_ELEMENTS_VERTICES = 0x80E8;
            case GL_ACTIVE_TEXTURE = 0x84E0;
            case GL_COLOR_WRITEMASK = 0x0C23;
            case GL_SHADER_STORAGE_BUFFER_START = 0x90D4;
            case GL_TEXTURE_VIEW_MIN_LAYER = 0x82DD;
            case GL_UNPACK_ALIGNMENT = 0x0CF5;
            case GL_PROGRAM_BINARY_FORMATS = 0x87FF;
            case GL_IMAGE_BINDING_LEVEL = 0x8F3B;
            case GL_MAX_FRAGMENT_IMAGE_UNIFORMS = 0x90CE;
            case GL_MAX_LABEL_LENGTH = 0x82E8;
            case GL_PACK_ROW_LENGTH = 0x0D02;
            case GL_LINE_WIDTH_GRANULARITY = 0x0B23;
            case GL_MAX_TESS_GEN_LEVEL = 0x8E7E;
            case GL_MAX_VERTEX_ATTRIB_STRIDE = 0x82E5;
            case GL_TEXTURE_BINDING_2D_ARRAY = 0x8C1D;
            case GL_MAX_GEOMETRY_ATOMIC_COUNTER_BUFFERS = 0x92CF;
            case GL_MAX_VERTEX_ATTRIB_RELATIVE_OFFSET = 0x82D9;
            case GL_MAX_TEXTURE_BUFFER_SIZE = 0x8C2B;
            case GL_MIN_PROGRAM_TEXEL_OFFSET = 0x8904;
            case GL_MAX_COMPUTE_ATOMIC_COUNTERS = 0x8265;
            case GL_MAX_GEOMETRY_TEXTURE_IMAGE_UNITS = 0x8C29;
            case GL_MAX_UNIFORM_BUFFER_BINDINGS = 0x8A2F;
            case GL_TIMESTAMP = 0x8E28;
            case GL_LINE_SMOOTH = 0x0B20;
            case GL_MAX_TESS_CONTROL_INPUT_COMPONENTS = 0x886C;
            case GL_MAX_VERTEX_IMAGE_UNIFORMS = 0x90CA;
            case GL_MAX_TEXTURE_LOD_BIAS = 0x84FD;
            case GL_STENCIL_BACK_REF = 0x8CA3;
            case GL_FRAGMENT_INTERPOLATION_OFFSET_BITS = 0x8E5D;
            case GL_MAX_FRAGMENT_UNIFORM_COMPONENTS = 0x8B49;
            case GL_UNIFORM_BUFFER_SIZE = 0x8A2A;
            case GL_MAX_GEOMETRY_OUTPUT_VERTICES = 0x8DE0;
            case GL_MIN_PROGRAM_TEXTURE_GATHER_OFFSET = 0x8E5E;
            case GL_CONTEXT_PROFILE_MASK = 0x9126;
            case GL_TEXTURE_BINDING_CUBE_MAP = 0x8514;
            case GL_MAX_RECTANGLE_TEXTURE_SIZE = 0x84F8;
            case GL_TEXTURE_VIEW_NUM_LAYERS = 0x82DE;
            case GL_DEBUG_NEXT_LOGGED_MESSAGE_LENGTH = 0x8243;
            case GL_IMPLEMENTATION_COLOR_READ_TYPE = 0x8B9A;
            case GL_MAX_COMBINED_SHADER_STORAGE_BLOCKS = 0x90DC;
            case GL_MAX_TESS_CONTROL_TEXTURE_IMAGE_UNITS = 0x8E81;
            case GL_MAX_COMPUTE_UNIFORM_BLOCKS = 0x91BB;
            case GL_ELEMENT_ARRAY_BUFFER_BINDING = 0x8895;
            case GL_FRAMEBUFFER_BINDING = 0x8CA6;
            case GL_MAX_TRANSFORM_FEEDBACK_INTERLEAVED_COMPONENTS = 0x8C8A;
            case GL_TEXTURE_BINDING_2D_MULTISAMPLE = 0x9104;
            case GL_DEBUG_LOGGED_MESSAGES = 0x9145;
            case GL_NUM_COMPRESSED_TEXTURE_FORMATS = 0x86A2;
            case GL_MAX_UNIFORM_LOCATIONS = 0x826E;
            case GL_MIN_SAMPLE_SHADING_VALUE = 0x8C37;
            case GL_MAX_TESS_PATCH_COMPONENTS = 0x8E84;
            case GL_DEPTH_WRITEMASK = 0x0B72;
            case GL_MAX_VARYING_VECTORS = 0x8DFC;
            case GL_LOGIC_OP_MODE = 0x0BF0;
            case GL_PRIMITIVE_RESTART_INDEX = 0x8F9E;
            case GL_VERTEX_PROGRAM_POINT_SIZE = 0x8642;
            case GL_SAMPLE_BUFFERS = 0x80A8;
            case GL_PACK_SKIP_IMAGES = 0x806B;
            case GL_TEXTURE_BINDING_RECTANGLE = 0x84F6;
            case GL_MAX_VARYING_COMPONENTS = 0x8B4B;
            case GL_MAX_SUBROUTINES = 0x8DE7;
            case GL_MAX_ATOMIC_COUNTER_BUFFER_BINDINGS = 0x92DC;
            case GL_UNPACK_SKIP_ROWS = 0x0CF3;
            case GL_TEXTURE_BUFFER_OFFSET_ALIGNMENT = 0x919F;
            case GL_MAX_FRAGMENT_UNIFORM_BLOCKS = 0x8A2D;
            case GL_POINT_SIZE = 0x0B11;
            case GL_SCISSOR_BOX = 0x0C10;
            case GL_MAX_TESS_EVALUATION_TEXTURE_IMAGE_UNITS = 0x8E82;
            case GL_SMOOTH_LINE_WIDTH_RANGE = 0x0B22;
            case GL_PACK_ALIGNMENT = 0x0D05;
            case GL_MAX_GEOMETRY_OUTPUT_COMPONENTS = 0x9124;
            case GL_TEXTURE_IMMUTABLE_LEVELS = 0x82DF;
            case GL_MAX_DRAW_BUFFERS = 0x8824;
            case GL_STENCIL_CLEAR_VALUE = 0x0B91;
            case GL_DRAW_BUFFER = 0x0C01;
            case GL_MAX_COMPUTE_ATOMIC_COUNTER_BUFFERS = 0x8264;
            case GL_UNIFORM_BUFFER_OFFSET_ALIGNMENT = 0x8A34;
            case GL_SMOOTH_POINT_SIZE_RANGE = 0x0B12;
            case GL_IMAGE_BINDING_FORMAT = 0x906E;
            case GL_MAX_COMPUTE_SHADER_STORAGE_BLOCKS = 0x90DB;
            case GL_MAX_COMPUTE_IMAGE_UNIFORMS = 0x91BD;
            case GL_FRONT_FACE = 0x0B46;
            case GL_POLYGON_OFFSET_UNITS = 0x2A00;
            case GL_LAYER_PROVOKING_VERTEX = 0x825E;
            case GL_BLEND_SRC = 0x0BE1;
            case GL_COLOR_LOGIC_OP = 0x0BF2;
            case GL_TRANSFORM_FEEDBACK_BUFFER_START = 0x8C84;
            case GL_MAX_TRANSFORM_FEEDBACK_BUFFERS = 0x8E70;
            case GL_STENCIL_TEST = 0x0B90;
            case GL_TEXTURE_BUFFER_BINDING = 0x8C2A;
            case GL_MAX_TESS_CONTROL_ATOMIC_COUNTERS = 0x92D3;
            case GL_POINT_FADE_THRESHOLD_SIZE = 0x8128;
            case GL_MAX_COMPUTE_SHARED_MEMORY_SIZE = 0x8262;
            case GL_MAX_VERTEX_OUTPUT_COMPONENTS = 0x9122;
            case GL_STEREO = 0x0C33;
            case GL_MAX_FRAMEBUFFER_HEIGHT = 0x9316;
            case GL_UNPACK_SKIP_IMAGES = 0x806D;
            case GL_MAX_GEOMETRY_UNIFORM_COMPONENTS = 0x8DDF;
            case GL_COPY_WRITE_BUFFER_BINDING = 0x8F37;
            case GL_TEXTURE_BINDING_CUBE_MAP_ARRAY = 0x900A;
            case GL_MAX_COMBINED_CLIP_AND_CULL_DISTANCES = 0x82FA;
            case GL_COPY_READ_BUFFER_BINDING = 0x8F36;
            case GL_UNIFORM_BUFFER_START = 0x8A29;
            case GL_MAX_VIEWPORT_DIMS = 0x0D3A;
            case GL_BLEND_DST = 0x0BE0;
            case GL_MAX_PATCH_VERTICES = 0x8E7D;
            case GL_MAX_TESS_CONTROL_UNIFORM_BLOCKS = 0x8E89;
            case GL_MAX_COMBINED_ATOMIC_COUNTER_BUFFERS = 0x92D1;
            case GL_DRAW_INDIRECT_BUFFER_BINDING = 0x8F43;
            case GL_UNPACK_SKIP_PIXELS = 0x0CF4;
            case GL_MAX_TRANSFORM_FEEDBACK_SEPARATE_ATTRIBS = 0x8C8B;
            case GL_BLEND_DST_ALPHA = 0x80CA;
            case GL_UNPACK_SWAP_BYTES = 0x0CF0;
            case GL_PACK_SKIP_ROWS = 0x0D03;
            case GL_SHADER_STORAGE_BUFFER_OFFSET_ALIGNMENT = 0x90DF;
            case GL_VIEWPORT_BOUNDS_RANGE = 0x825D;
            case GL_NUM_PROGRAM_BINARY_FORMATS = 0x87FE;
            case GL_MAX_TEXTURE_IMAGE_UNITS = 0x8872;
            case GL_SAMPLER_BINDING = 0x8919;
            case GL_MAX_SHADER_STORAGE_BUFFER_BINDINGS = 0x90DD;
            case GL_BLEND_SRC_ALPHA = 0x80CB;
            case GL_MAX_VERTEX_ATTRIBS = 0x8869;
            case GL_COLOR_CLEAR_VALUE = 0x0C22;
            case GL_BLEND_EQUATION_RGB = 0x8009;
            case GL_MAX_GEOMETRY_SHADER_INVOCATIONS = 0x8E5A;
            case GL_MAX_ATOMIC_COUNTER_BUFFER_SIZE = 0x92D8;
            case GL_MAX_CLIP_DISTANCES = 0x0D32;
            case GL_MAX_VERTEX_UNIFORM_COMPONENTS = 0x8B4A;
            case GL_MAX_FRAGMENT_INPUT_COMPONENTS = 0x9125;
            case GL_POLYGON_SMOOTH = 0x0B41;
            case GL_POINT_SIZE_GRANULARITY = 0x0B13;
            case GL_NUM_EXTENSIONS = 0x821D;
            case GL_MAX_ARRAY_TEXTURE_LAYERS = 0x88FF;
            case GL_STENCIL_PASS_DEPTH_FAIL = 0x0B95;
            case GL_MAX_DUAL_SOURCE_DRAW_BUFFERS = 0x88FC;
            case GL_SAMPLE_COVERAGE_INVERT = 0x80AB;
            case GL_MAX_DEBUG_GROUP_STACK_DEPTH = 0x826C;
            case GL_MAX_INTEGER_SAMPLES = 0x9110;
            case GL_CURRENT_PROGRAM = 0x8B8D;
            case GL_MAX_TESS_CONTROL_ATOMIC_COUNTER_BUFFERS = 0x92CD;
            case GL_POLYGON_OFFSET_POINT = 0x2A01;
            case GL_MAX_COMBINED_COMPUTE_UNIFORM_COMPONENTS = 0x8266;
            case GL_PROVOKING_VERTEX = 0x8E4F;
            case GL_MAX_FRAGMENT_ATOMIC_COUNTERS = 0x92D6;
            case GL_DEPTH_RANGE = 0x0B70;
            case GL_MAX_COMBINED_SHADER_OUTPUT_RESOURCES = 0x8F39;
            case GL_BLEND_EQUATION = 0x8009;
            case GL_POLYGON_OFFSET_FILL = 0x8037;
            case GL_DRAW_FRAMEBUFFER_BINDING = 0x8CA6;
            case GL_MAX_GEOMETRY_SHADER_STORAGE_BLOCKS = 0x90D7;
            case GL_SAMPLE_MASK_VALUE = 0x8E52;
            case GL_PROGRAM_POINT_SIZE = 0x8642;
            case GL_MAX_UNIFORM_BLOCK_SIZE = 0x8A30;
            case GL_STENCIL_FUNC = 0x0B92;
            case GL_MAX_COMPUTE_UNIFORM_COMPONENTS = 0x8263;
            case GL_MAX_TRANSFORM_FEEDBACK_SEPARATE_COMPONENTS = 0x8C80;
            case GL_TEXTURE_BINDING_1D = 0x8068;
            case GL_MAX_VERTEX_STREAMS = 0x8E71;
            case GL_IMPLEMENTATION_COLOR_READ_FORMAT = 0x8B9B;
            case GL_MAX_CULL_DISTANCES = 0x82F9;
            case GL_MAX_PROGRAM_TEXTURE_GATHER_OFFSET = 0x8E5F;
            case GL_TRANSFORM_FEEDBACK_BUFFER_BINDING = 0x8C8F;
            case GL_MAX_TESS_CONTROL_TOTAL_OUTPUT_COMPONENTS = 0x8E85;
            case GL_MAX_COLOR_ATTACHMENTS = 0x8CDF;
            case GL_STENCIL_BACK_PASS_DEPTH_FAIL = 0x8802;
            case GL_COMPRESSED_TEXTURE_FORMATS = 0x86A3;
            case GL_VERTEX_BINDING_OFFSET = 0x82D7;
            case GL_DITHER = 0x0BD0;
            case GL_MAX_SHADER_STORAGE_BLOCK_SIZE = 0x90DE;
            case GL_SAMPLES = 0x80A9;
            case GL_TEXTURE_BINDING_BUFFER = 0x8C2C;
            case GL_MINOR_VERSION = 0x821C;
            case GL_LINE_WIDTH = 0x0B21;
            case GL_STENCIL_FAIL = 0x0B94;
            case GL_MAX_TESS_EVALUATION_SHADER_STORAGE_BLOCKS = 0x90D9;
            case GL_STENCIL_WRITEMASK = 0x0B98;
            case GL_DEBUG_GROUP_STACK_DEPTH = 0x826D;
            case GL_TEXTURE_BINDING_1D_ARRAY = 0x8C1C;
            case GL_UNPACK_LSB_FIRST = 0x0CF1;
            case GL_TEXTURE_BINDING_2D = 0x8069;
            case GL_MAX_GEOMETRY_ATOMIC_COUNTERS = 0x92D5;
            case GL_MAX_COMBINED_TEXTURE_IMAGE_UNITS = 0x8B4D;
            case GL_MAX_VERTEX_SHADER_STORAGE_BLOCKS = 0x90D6;
            case GL_SUBPIXEL_BITS = 0x0D50;
            case GL_MAX_TESS_CONTROL_SHADER_STORAGE_BLOCKS = 0x90D8;
            case GL_MAX_GEOMETRY_UNIFORM_BLOCKS = 0x8A2C;
            case GL_POLYGON_SMOOTH_HINT = 0x0C53;
            case GL_TEXTURE_COMPRESSION_HINT = 0x84EF;
            case GL_MAX_VIEWPORTS = 0x825B;
            case GL_MAX_COMPUTE_WORK_GROUP_INVOCATIONS = 0x90EB;
            case GL_VERTEX_ARRAY_BINDING = 0x85B5;
            case GL_IMAGE_BINDING_LAYERED = 0x8F3C;
            case GL_CULL_FACE_MODE = 0x0B45;
            case GL_MAX_COMBINED_VERTEX_UNIFORM_COMPONENTS = 0x8A31;
            case GL_MAX_TESS_EVALUATION_ATOMIC_COUNTER_BUFFERS = 0x92CE;
            case GL_READ_BUFFER = 0x0C02;
            case GL_MAX_FRAMEBUFFER_WIDTH = 0x9315;
            case GL_DISPATCH_INDIRECT_BUFFER_BINDING = 0x90EF;
            case GL_PIXEL_UNPACK_BUFFER_BINDING = 0x88EF;
            case GL_TEXTURE_BINDING_3D = 0x806A;
            case GL_MAX_ELEMENT_INDEX = 0x8D6B;
            case GL_MAX_SUBROUTINE_UNIFORM_LOCATIONS = 0x8DE8;
            case GL_BLEND_DST_RGB = 0x80C8;
            case GL_MAX_COMBINED_UNIFORM_BLOCKS = 0x8A2E;
            case GL_MAX_ELEMENTS_INDICES = 0x80E9;
            case GL_MAX_IMAGE_SAMPLES = 0x906D;
            case GL_MAX_TESS_EVALUATION_UNIFORM_COMPONENTS = 0x8E80;
            case GL_BLEND = 0x0BE2;
            case GL_MAX_COLOR_TEXTURE_SAMPLES = 0x910E;
			public static implicit operator Self(uint32 num)
			{
				var a = Self();
				a.UnderlyingRef = num;
				return a;
			}
        }

        [AllowDuplicates]
        public enum FramebufferAttachmentParameterName : uint32 {
            case GL_FRAMEBUFFER_ATTACHMENT_GREEN_SIZE = 0x8213;
            case GL_FRAMEBUFFER_ATTACHMENT_OBJECT_TYPE = 0x8CD0;
            case GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_LEVEL = 0x8CD2;
            case GL_FRAMEBUFFER_ATTACHMENT_LAYERED = 0x8DA7;
            case GL_FRAMEBUFFER_ATTACHMENT_BLUE_SIZE = 0x8214;
            case GL_FRAMEBUFFER_ATTACHMENT_DEPTH_SIZE = 0x8216;
            case GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_LAYER = 0x8CD4;
            case GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_CUBE_MAP_FACE = 0x8CD3;
            case GL_FRAMEBUFFER_ATTACHMENT_COMPONENT_TYPE = 0x8211;
            case GL_FRAMEBUFFER_ATTACHMENT_STENCIL_SIZE = 0x8217;
            case GL_FRAMEBUFFER_ATTACHMENT_ALPHA_SIZE = 0x8215;
            case GL_FRAMEBUFFER_ATTACHMENT_RED_SIZE = 0x8212;
            case GL_FRAMEBUFFER_ATTACHMENT_COLOR_ENCODING = 0x8210;
            case GL_FRAMEBUFFER_ATTACHMENT_OBJECT_NAME = 0x8CD1;
        }

        [AllowDuplicates]
        public enum ClipPlaneName : uint32 {
            case GL_CLIP_DISTANCE1 = 0x3001;
            case GL_CLIP_DISTANCE0 = 0x3000;
            case GL_CLIP_DISTANCE3 = 0x3003;
            case GL_CLIP_DISTANCE2 = 0x3002;
            case GL_CLIP_DISTANCE5 = 0x3005;
            case GL_CLIP_DISTANCE4 = 0x3004;
            case GL_CLIP_DISTANCE7 = 0x3007;
            case GL_CLIP_DISTANCE6 = 0x3006;
        }

        [AllowDuplicates]
        public enum FramebufferTarget : uint32 {
            case GL_DRAW_FRAMEBUFFER = 0x8CA9;
            case GL_READ_FRAMEBUFFER = 0x8CA8;
            case GL_FRAMEBUFFER = 0x8D40;
        }

        [AllowDuplicates]
        public enum DrawElementsType : uint32 {
            case GL_UNSIGNED_SHORT = 0x1403;
            case GL_UNSIGNED_BYTE = 0x1401;
            case GL_UNSIGNED_INT = 0x1405;
        }

        [AllowDuplicates]
        public enum TextureMagFilter : uint32 {
            case GL_LINEAR = 0x2601;
            case GL_NEAREST = 0x2600;
        }

        [AllowDuplicates]
        public enum PrecisionType : uint32 {
            case GL_MEDIUM_FLOAT = 0x8DF1;
            case GL_HIGH_FLOAT = 0x8DF2;
            case GL_LOW_FLOAT = 0x8DF0;
            case GL_LOW_INT = 0x8DF3;
            case GL_MEDIUM_INT = 0x8DF4;
            case GL_HIGH_INT = 0x8DF5;
        }

        [AllowDuplicates]
        public enum ProgramResourceProperty : uint32 {
            case GL_REFERENCED_BY_VERTEX_SHADER = 0x9306;
            case GL_NAME_LENGTH = 0x92F9;
            case GL_BUFFER_BINDING = 0x9302;
            case GL_TOP_LEVEL_ARRAY_STRIDE = 0x930D;
            case GL_MATRIX_STRIDE = 0x92FF;
            case GL_REFERENCED_BY_GEOMETRY_SHADER = 0x9309;
            case GL_UNIFORM = 0x92E1;
            case GL_ACTIVE_VARIABLES = 0x9305;
            case GL_ARRAY_STRIDE = 0x92FE;
            case GL_BUFFER_DATA_SIZE = 0x9303;
            case GL_REFERENCED_BY_TESS_CONTROL_SHADER = 0x9307;
            case GL_NUM_COMPATIBLE_SUBROUTINES = 0x8E4A;
            case GL_ATOMIC_COUNTER_BUFFER_INDEX = 0x9301;
            case GL_REFERENCED_BY_COMPUTE_SHADER = 0x930B;
            case GL_BLOCK_INDEX = 0x92FD;
            case GL_LOCATION = 0x930E;
            case GL_OFFSET = 0x92FC;
            case GL_IS_ROW_MAJOR = 0x9300;
            case GL_TRANSFORM_FEEDBACK_BUFFER_INDEX = 0x934B;
            case GL_TOP_LEVEL_ARRAY_SIZE = 0x930C;
            case GL_TRANSFORM_FEEDBACK_BUFFER_STRIDE = 0x934C;
            case GL_NUM_ACTIVE_VARIABLES = 0x9304;
            case GL_REFERENCED_BY_TESS_EVALUATION_SHADER = 0x9308;
            case GL_COMPATIBLE_SUBROUTINES = 0x8E4B;
            case GL_LOCATION_INDEX = 0x930F;
            case GL_LOCATION_COMPONENT = 0x934A;
            case GL_TYPE = 0x92FA;
            case GL_ARRAY_SIZE = 0x92FB;
            case GL_IS_PER_PATCH = 0x92E7;
            case GL_REFERENCED_BY_FRAGMENT_SHADER = 0x930A;
        }

        [AllowDuplicates]
        public enum FogMode : uint32 {
            case GL_LINEAR = 0x2601;
        }

        [AllowDuplicates]
        public enum FramebufferStatus : uint32 {
            case GL_FRAMEBUFFER_COMPLETE = 0x8CD5;
            case GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT = 0x8CD6;
            case GL_FRAMEBUFFER_INCOMPLETE_DRAW_BUFFER = 0x8CDB;
            case GL_FRAMEBUFFER_UNSUPPORTED = 0x8CDD;
            case GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT = 0x8CD7;
            case GL_FRAMEBUFFER_INCOMPLETE_READ_BUFFER = 0x8CDC;
            case GL_FRAMEBUFFER_INCOMPLETE_MULTISAMPLE = 0x8D56;
            case GL_FRAMEBUFFER_INCOMPLETE_LAYER_TARGETS = 0x8DA8;
            case GL_FRAMEBUFFER_UNDEFINED = 0x8219;
        }

        [AllowDuplicates]
        public enum VertexAttribPointerType : uint32 {
            case GL_INT_2_10_10_10_REV = 0x8D9F;
            case GL_FLOAT = 0x1406;
            case GL_DOUBLE = 0x140A;
            case GL_BYTE = 0x1400;
            case GL_HALF_FLOAT = 0x140B;
            case GL_UNSIGNED_INT = 0x1405;
            case GL_UNSIGNED_INT_2_10_10_10_REV = 0x8368;
            case GL_INT = 0x1404;
            case GL_UNSIGNED_INT_10F_11F_11F_REV = 0x8C3B;
            case GL_UNSIGNED_SHORT = 0x1403;
            case GL_FIXED = 0x140C;
            case GL_UNSIGNED_BYTE = 0x1401;
            case GL_SHORT = 0x1402;
        }

        [AllowDuplicates]
        public enum VertexShaderWriteMaskEXT : uint32 {
            case GL_TRUE = 1;
            case GL_FALSE = 0;
        }

        [AllowDuplicates]
        public enum StringName : uint32 {
            case GL_VERSION = 0x1F02;
            case GL_SHADING_LANGUAGE_VERSION = 0x8B8C;
            case GL_VENDOR = 0x1F00;
            case GL_RENDERER = 0x1F01;
            case GL_EXTENSIONS = 0x1F03;
        }

        [AllowDuplicates]
        public enum VertexAttribPropertyARB : uint32 {
            case GL_VERTEX_ATTRIB_ARRAY_ENABLED = 0x8622;
            case GL_VERTEX_ATTRIB_ARRAY_DIVISOR = 0x88FE;
            case GL_VERTEX_ATTRIB_ARRAY_TYPE = 0x8625;
            case GL_CURRENT_VERTEX_ATTRIB = 0x8626;
            case GL_VERTEX_ATTRIB_ARRAY_LONG = 0x874E;
            case GL_VERTEX_ATTRIB_ARRAY_INTEGER = 0x88FD;
            case GL_VERTEX_ATTRIB_RELATIVE_OFFSET = 0x82D5;
            case GL_VERTEX_ATTRIB_ARRAY_SIZE = 0x8623;
            case GL_VERTEX_ATTRIB_ARRAY_STRIDE = 0x8624;
            case GL_VERTEX_ATTRIB_ARRAY_NORMALIZED = 0x886A;
            case GL_VERTEX_ATTRIB_ARRAY_BUFFER_BINDING = 0x889F;
            case GL_VERTEX_ATTRIB_BINDING = 0x82D4;
        }

        [AllowDuplicates]
        public enum PixelCopyType : uint32 {
            case GL_DEPTH = 0x1801;
            case GL_COLOR = 0x1800;
            case GL_STENCIL = 0x1802;
        }

        [AllowDuplicates]
        public enum ListNameType : uint32 {
            case GL_FLOAT = 0x1406;
            case GL_BYTE = 0x1400;
            case GL_INT = 0x1404;
            case GL_UNSIGNED_SHORT = 0x1403;
            case GL_UNSIGNED_BYTE = 0x1401;
            case GL_SHORT = 0x1402;
            case GL_UNSIGNED_INT = 0x1405;
        }

        [AllowDuplicates]
        public enum GetTextureParameter : uint32 {
            case GL_TEXTURE_DEPTH_TYPE = 0x8C16;
            case GL_TEXTURE_ALPHA_TYPE = 0x8C13;
            case GL_TEXTURE_HEIGHT = 0x1001;
            case GL_TEXTURE_STENCIL_SIZE = 0x88F1;
            case GL_TEXTURE_VIEW_MIN_LEVEL = 0x82DB;
            case GL_TEXTURE_IMMUTABLE_FORMAT = 0x912F;
            case GL_TEXTURE_DEPTH_SIZE = 0x884A;
            case GL_TEXTURE_SHARED_SIZE = 0x8C3F;
            case GL_TEXTURE_COMPRESSED_IMAGE_SIZE = 0x86A0;
            case GL_TEXTURE_BUFFER_OFFSET = 0x919D;
            case GL_TEXTURE_MIN_FILTER = 0x2801;
            case GL_TEXTURE_BLUE_TYPE = 0x8C12;
            case GL_TEXTURE_DEPTH = 0x8071;
            case GL_TEXTURE_IMMUTABLE_LEVELS = 0x82DF;
            case GL_TEXTURE_BLUE_SIZE = 0x805E;
            case GL_TEXTURE_WIDTH = 0x1000;
            case GL_TEXTURE_FIXED_SAMPLE_LOCATIONS = 0x9107;
            case GL_TEXTURE_TARGET = 0x1006;
            case GL_TEXTURE_GREEN_SIZE = 0x805D;
            case GL_TEXTURE_GREEN_TYPE = 0x8C11;
            case GL_TEXTURE_VIEW_NUM_LAYERS = 0x82DE;
            case GL_TEXTURE_BUFFER_SIZE = 0x919E;
            case GL_TEXTURE_MAG_FILTER = 0x2800;
            case GL_TEXTURE_WRAP_S = 0x2802;
            case GL_TEXTURE_WRAP_T = 0x2803;
            case GL_TEXTURE_BUFFER_DATA_STORE_BINDING = 0x8C2D;
            case GL_TEXTURE_INTERNAL_FORMAT = 0x1003;
            case GL_TEXTURE_RED_SIZE = 0x805C;
            case GL_TEXTURE_VIEW_NUM_LEVELS = 0x82DC;
            case GL_TEXTURE_ALPHA_SIZE = 0x805F;
            case GL_TEXTURE_RED_TYPE = 0x8C10;
            case GL_TEXTURE_VIEW_MIN_LAYER = 0x82DD;
            case GL_TEXTURE_BORDER_COLOR = 0x1004;
        }

        [AllowDuplicates]
        public enum ProgramStagePName : uint32 {
            case GL_ACTIVE_SUBROUTINE_UNIFORM_LOCATIONS = 0x8E47;
            case GL_ACTIVE_SUBROUTINE_UNIFORM_MAX_LENGTH = 0x8E49;
            case GL_ACTIVE_SUBROUTINES = 0x8DE5;
            case GL_ACTIVE_SUBROUTINE_MAX_LENGTH = 0x8E48;
            case GL_ACTIVE_SUBROUTINE_UNIFORMS = 0x8DE6;
        }

        [AllowDuplicates]
        public enum ObjectIdentifier : uint32 {
            case GL_PROGRAM = 0x82E2;
            case GL_SHADER = 0x82E1;
            case GL_TRANSFORM_FEEDBACK = 0x8E22;
            case GL_BUFFER = 0x82E0;
            case GL_QUERY = 0x82E3;
            case GL_FRAMEBUFFER = 0x8D40;
            case GL_TEXTURE = 0x1702;
            case GL_RENDERBUFFER = 0x8D41;
            case GL_PROGRAM_PIPELINE = 0x82E4;
            case GL_SAMPLER = 0x82E6;
        }

        [AllowDuplicates]
        public enum PixelTexGenMode : uint32 {
            case GL_RGB = 0x1907;
            case GL_RGBA = 0x1908;
            case GL_NONE = 0;
        }

        [AllowDuplicates]
        public enum TextureCompareMode : uint32 {
            case GL_COMPARE_REF_TO_TEXTURE = 0x884E;
            case GL_NONE = 0;
        }

        [AllowDuplicates]
        public enum ClipControlDepth : uint32 {
            case GL_ZERO_TO_ONE = 0x935F;
            case GL_NEGATIVE_ONE_TO_ONE = 0x935E;
        }

        [AllowDuplicates]
        public enum SubroutineParameterName : uint32 {
            case GL_UNIFORM_SIZE = 0x8A38;
            case GL_UNIFORM_NAME_LENGTH = 0x8A39;
            case GL_NUM_COMPATIBLE_SUBROUTINES = 0x8E4A;
            case GL_COMPATIBLE_SUBROUTINES = 0x8E4B;
        }

        [AllowDuplicates]
        public enum ConvolutionTarget : uint32 {
            case GL_CONVOLUTION_2D = 0x8011;
            case GL_CONVOLUTION_1D = 0x8010;
        }

        [AllowDuplicates]
        public enum PathFontStyle : uint32 {
            case GL_NONE = 0;
        }

        [AllowDuplicates]
        public enum SeparableTarget : uint32 {
            case GL_SEPARABLE_2D = 0x8012;
        }

        [AllowDuplicates]
        public enum CopyImageSubDataTarget : uint32 {
            case GL_TEXTURE_2D = 0x0DE1;
            case GL_TEXTURE_1D_ARRAY = 0x8C18;
            case GL_TEXTURE_1D = 0x0DE0;
            case GL_TEXTURE_CUBE_MAP_ARRAY = 0x9009;
            case GL_TEXTURE_RECTANGLE = 0x84F5;
            case GL_TEXTURE_2D_MULTISAMPLE_ARRAY = 0x9102;
            case GL_TEXTURE_2D_ARRAY = 0x8C1A;
            case GL_TEXTURE_2D_MULTISAMPLE = 0x9100;
            case GL_RENDERBUFFER = 0x8D41;
            case GL_TEXTURE_CUBE_MAP = 0x8513;
            case GL_TEXTURE_3D = 0x806F;
        }

        [AllowDuplicates]
        public enum NormalPointerType : uint32 {
            case GL_FLOAT = 0x1406;
            case GL_DOUBLE = 0x140A;
            case GL_BYTE = 0x1400;
            case GL_INT = 0x1404;
            case GL_SHORT = 0x1402;
        }

        [AllowDuplicates]
        public enum QueryCounterTarget : uint32 {
            case GL_TIMESTAMP = 0x8E28;
        }

        [AllowDuplicates]
        public enum ContextProfileMask : uint32 {
            case GL_CONTEXT_CORE_PROFILE_BIT = 0x00000001;
            case GL_CONTEXT_COMPATIBILITY_PROFILE_BIT = 0x00000002;
        }

        [AllowDuplicates]
        public enum PatchParameterName : uint32 {
            case GL_PATCH_VERTICES = 0x8E72;
            case GL_PATCH_DEFAULT_OUTER_LEVEL = 0x8E74;
            case GL_PATCH_DEFAULT_INNER_LEVEL = 0x8E73;
        }

        [AllowDuplicates]
        public enum ColorMaterialFace : uint32 {
            case GL_FRONT = 0x0404;
            case GL_BACK = 0x0405;
            case GL_FRONT_AND_BACK = 0x0408;
        }

        [AllowDuplicates]
        public enum ShaderType : uint32 {
            case GL_VERTEX_SHADER = 0x8B31;
            case GL_COMPUTE_SHADER = 0x91B9;
            case GL_GEOMETRY_SHADER = 0x8DD9;
            case GL_TESS_CONTROL_SHADER = 0x8E88;
            case GL_FRAGMENT_SHADER = 0x8B30;
            case GL_TESS_EVALUATION_SHADER = 0x8E87;
        }

        [AllowDuplicates]
        public enum FogCoordinatePointerType : uint32 {
            case GL_FLOAT = 0x1406;
            case GL_DOUBLE = 0x140A;
        }

        [AllowDuplicates]
        public enum MatrixIndexPointerTypeARB : uint32 {
            case GL_UNSIGNED_SHORT = 0x1403;
            case GL_UNSIGNED_BYTE = 0x1401;
            case GL_UNSIGNED_INT = 0x1405;
        }

        [AllowDuplicates]
        public enum CombinerPortionNV : uint32 {
            case GL_RGB = 0x1907;
            case GL_ALPHA = 0x1906;
        }

        [AllowDuplicates]
        public enum VertexArrayPName : uint32 {
            case GL_VERTEX_ATTRIB_ARRAY_ENABLED = 0x8622;
            case GL_VERTEX_ATTRIB_ARRAY_DIVISOR = 0x88FE;
            case GL_VERTEX_ATTRIB_ARRAY_TYPE = 0x8625;
            case GL_VERTEX_ATTRIB_ARRAY_LONG = 0x874E;
            case GL_VERTEX_ATTRIB_ARRAY_INTEGER = 0x88FD;
            case GL_VERTEX_ATTRIB_RELATIVE_OFFSET = 0x82D5;
            case GL_VERTEX_ATTRIB_ARRAY_SIZE = 0x8623;
            case GL_VERTEX_ATTRIB_ARRAY_STRIDE = 0x8624;
            case GL_VERTEX_ATTRIB_ARRAY_NORMALIZED = 0x886A;
        }

        [AllowDuplicates]
        public enum HistogramTarget : uint32 {
            case GL_PROXY_HISTOGRAM = 0x8025;
            case GL_HISTOGRAM = 0x8024;
        }

        [AllowDuplicates]
        public enum TexCoordPointerType : uint32 {
            case GL_FLOAT = 0x1406;
            case GL_DOUBLE = 0x140A;
            case GL_INT = 0x1404;
            case GL_SHORT = 0x1402;
        }

        [AllowDuplicates]
        public enum TextureUnit : uint32 {
            case GL_TEXTURE20 = 0x84D4;
            case GL_TEXTURE19 = 0x84D3;
            case GL_TEXTURE18 = 0x84D2;
            case GL_TEXTURE17 = 0x84D1;
            case GL_TEXTURE16 = 0x84D0;
            case GL_TEXTURE15 = 0x84CF;
            case GL_TEXTURE14 = 0x84CE;
            case GL_TEXTURE13 = 0x84CD;
            case GL_TEXTURE12 = 0x84CC;
            case GL_TEXTURE11 = 0x84CB;
            case GL_TEXTURE10 = 0x84CA;
            case GL_TEXTURE31 = 0x84DF;
            case GL_TEXTURE30 = 0x84DE;
            case GL_TEXTURE0 = 0x84C0;
            case GL_TEXTURE4 = 0x84C4;
            case GL_TEXTURE3 = 0x84C3;
            case GL_TEXTURE2 = 0x84C2;
            case GL_TEXTURE1 = 0x84C1;
            case GL_TEXTURE8 = 0x84C8;
            case GL_TEXTURE7 = 0x84C7;
            case GL_TEXTURE6 = 0x84C6;
            case GL_TEXTURE5 = 0x84C5;
            case GL_TEXTURE29 = 0x84DD;
            case GL_TEXTURE28 = 0x84DC;
            case GL_TEXTURE27 = 0x84DB;
            case GL_TEXTURE26 = 0x84DA;
            case GL_TEXTURE9 = 0x84C9;
            case GL_TEXTURE25 = 0x84D9;
            case GL_TEXTURE24 = 0x84D8;
            case GL_TEXTURE23 = 0x84D7;
            case GL_TEXTURE22 = 0x84D6;
            case GL_TEXTURE21 = 0x84D5;
        }

        [AllowDuplicates]
        public enum PointParameterNameARB : uint32 {
            case GL_POINT_FADE_THRESHOLD_SIZE = 0x8128;
            case GL_POINT_SPRITE_COORD_ORIGIN = 0x8CA0;
        }

        [AllowDuplicates]
        public enum PathFillMode : uint32 {
            case GL_INVERT = 0x150A;
        }

        [AllowDuplicates]
        public enum HistogramTargetEXT : uint32 {
            case GL_PROXY_HISTOGRAM = 0x8025;
            case GL_HISTOGRAM = 0x8024;
        }

        [AllowDuplicates]
        public enum BufferUsageARB : uint32 {
            case GL_STATIC_COPY = 0x88E6;
            case GL_STATIC_DRAW = 0x88E4;
            case GL_STREAM_READ = 0x88E1;
            case GL_DYNAMIC_DRAW = 0x88E8;
            case GL_DYNAMIC_READ = 0x88E9;
            case GL_DYNAMIC_COPY = 0x88EA;
            case GL_STATIC_READ = 0x88E5;
            case GL_STREAM_DRAW = 0x88E0;
            case GL_STREAM_COPY = 0x88E2;
        }

        [AllowDuplicates]
        public enum BindTransformFeedbackTarget : uint32 {
            case GL_TRANSFORM_FEEDBACK = 0x8E22;
        }

        [AllowDuplicates]
        public enum CombinerComponentUsageNV : uint32 {
            case GL_BLUE = 0x1905;
            case GL_RGB = 0x1907;
            case GL_ALPHA = 0x1906;
        }

        [AllowDuplicates]
        public enum TransformFeedbackBufferMode : uint32 {
            case GL_INTERLEAVED_ATTRIBS = 0x8C8C;
            case GL_SEPARATE_ATTRIBS = 0x8C8D;
        }

        [AllowDuplicates]
        public enum AttributeType : uint32 {
            case GL_IMAGE_1D_ARRAY = 0x9052;
            case GL_IMAGE_3D = 0x904E;
            case GL_SAMPLER_2D_MULTISAMPLE_ARRAY = 0x910B;
            case GL_UNSIGNED_INT_SAMPLER_2D = 0x8DD2;
            case GL_INT_IMAGE_2D_RECT = 0x905A;
            case GL_UNSIGNED_INT_VEC4 = 0x8DC8;
            case GL_UNSIGNED_INT = 0x1405;
            case GL_INT_SAMPLER_1D_ARRAY = 0x8DCE;
            case GL_INT_SAMPLER_2D_ARRAY = 0x8DCF;
            case GL_INT_IMAGE_CUBE = 0x905B;
            case GL_IMAGE_2D_ARRAY = 0x9053;
            case GL_IMAGE_2D_MULTISAMPLE_ARRAY = 0x9056;
            case GL_INT_SAMPLER_CUBE_MAP_ARRAY = 0x900E;
            case GL_INT_SAMPLER_BUFFER = 0x8DD0;
            case GL_UNSIGNED_INT_IMAGE_1D_ARRAY = 0x9068;
            case GL_FLOAT_MAT3x4 = 0x8B68;
            case GL_UNSIGNED_INT_SAMPLER_1D = 0x8DD1;
            case GL_INT_IMAGE_2D_ARRAY = 0x905E;
            case GL_FLOAT_MAT3x2 = 0x8B67;
            case GL_IMAGE_BUFFER = 0x9051;
            case GL_BOOL_VEC4 = 0x8B59;
            case GL_BOOL_VEC3 = 0x8B58;
            case GL_INT_IMAGE_2D_MULTISAMPLE_ARRAY = 0x9061;
            case GL_UNSIGNED_INT_IMAGE_BUFFER = 0x9067;
            case GL_BOOL_VEC2 = 0x8B57;
            case GL_UNSIGNED_INT_VEC3 = 0x8DC7;
            case GL_UNSIGNED_INT_VEC2 = 0x8DC6;
            case GL_SAMPLER_CUBE_SHADOW = 0x8DC5;
            case GL_SAMPLER_BUFFER = 0x8DC2;
            case GL_UNSIGNED_INT_IMAGE_2D_MULTISAMPLE = 0x906B;
            case GL_UNSIGNED_INT_IMAGE_2D = 0x9063;
            case GL_UNSIGNED_INT_IMAGE_CUBE_MAP_ARRAY = 0x906A;
            case GL_UNSIGNED_INT_SAMPLER_BUFFER = 0x8DD8;
            case GL_UNSIGNED_INT_IMAGE_2D_MULTISAMPLE_ARRAY = 0x906C;
            case GL_FLOAT_MAT4 = 0x8B5C;
            case GL_FLOAT_MAT3 = 0x8B5B;
            case GL_FLOAT_MAT2 = 0x8B5A;
            case GL_UNSIGNED_INT_SAMPLER_2D_RECT = 0x8DD5;
            case GL_UNSIGNED_INT_SAMPLER_2D_MULTISAMPLE = 0x910A;
            case GL_SAMPLER_2D_ARRAY_SHADOW = 0x8DC4;
            case GL_INT_SAMPLER_2D_MULTISAMPLE_ARRAY = 0x910C;
            case GL_UNSIGNED_INT_SAMPLER_2D_ARRAY = 0x8DD7;
            case GL_IMAGE_2D_RECT = 0x904F;
            case GL_UNSIGNED_INT_SAMPLER_CUBE_MAP_ARRAY = 0x900F;
            case GL_UNSIGNED_INT_IMAGE_2D_RECT = 0x9065;
            case GL_INT_IMAGE_BUFFER = 0x905C;
            case GL_INT_SAMPLER_1D = 0x8DC9;
            case GL_SAMPLER_1D_SHADOW = 0x8B61;
            case GL_UNSIGNED_INT_IMAGE_1D = 0x9062;
            case GL_UNSIGNED_INT_SAMPLER_3D = 0x8DD3;
            case GL_UNSIGNED_INT_IMAGE_2D_ARRAY = 0x9069;
            case GL_FLOAT_MAT4x3 = 0x8B6A;
            case GL_DOUBLE_VEC4 = 0x8FFE;
            case GL_DOUBLE_VEC3 = 0x8FFD;
            case GL_SAMPLER_2D_MULTISAMPLE = 0x9108;
            case GL_FLOAT_MAT4x2 = 0x8B69;
            case GL_DOUBLE_VEC2 = 0x8FFC;
            case GL_INT_SAMPLER_CUBE = 0x8DCC;
            case GL_INT_IMAGE_2D_MULTISAMPLE = 0x9060;
            case GL_DOUBLE_MAT2x4 = 0x8F4A;
            case GL_INT_IMAGE_1D_ARRAY = 0x905D;
            case GL_DOUBLE_MAT2x3 = 0x8F49;
            case GL_INT_SAMPLER_2D_MULTISAMPLE = 0x9109;
            case GL_INT_VEC4 = 0x8B55;
            case GL_INT_VEC2 = 0x8B53;
            case GL_INT_VEC3 = 0x8B54;
            case GL_SAMPLER_CUBE_MAP_ARRAY_SHADOW = 0x900D;
            case GL_FLOAT = 0x1406;
            case GL_SAMPLER_2D_RECT_SHADOW = 0x8B64;
            case GL_INT_SAMPLER_3D = 0x8DCB;
            case GL_UNSIGNED_INT_IMAGE_CUBE = 0x9066;
            case GL_SAMPLER_2D_SHADOW = 0x8B62;
            case GL_DOUBLE = 0x140A;
            case GL_UNSIGNED_INT_IMAGE_3D = 0x9064;
            case GL_SAMPLER_3D = 0x8B5F;
            case GL_DOUBLE_MAT4 = 0x8F48;
            case GL_DOUBLE_MAT3x4 = 0x8F4C;
            case GL_DOUBLE_MAT3x2 = 0x8F4B;
            case GL_INT_SAMPLER_2D = 0x8DCA;
            case GL_SAMPLER_1D_ARRAY_SHADOW = 0x8DC3;
            case GL_UNSIGNED_INT_SAMPLER_2D_MULTISAMPLE_ARRAY = 0x910D;
            case GL_DOUBLE_MAT3 = 0x8F47;
            case GL_DOUBLE_MAT2 = 0x8F46;
            case GL_IMAGE_CUBE_MAP_ARRAY = 0x9054;
            case GL_INT_IMAGE_CUBE_MAP_ARRAY = 0x905F;
            case GL_UNSIGNED_INT_SAMPLER_CUBE = 0x8DD4;
            case GL_IMAGE_CUBE = 0x9050;
            case GL_SAMPLER_2D = 0x8B5E;
            case GL_INT_IMAGE_1D = 0x9057;
            case GL_SAMPLER_CUBE_MAP_ARRAY = 0x900C;
            case GL_UNSIGNED_INT_SAMPLER_1D_ARRAY = 0x8DD6;
            case GL_IMAGE_2D_MULTISAMPLE = 0x9055;
            case GL_IMAGE_1D = 0x904C;
            case GL_BOOL = 0x8B56;
            case GL_SAMPLER_CUBE = 0x8B60;
            case GL_FLOAT_MAT2x3 = 0x8B65;
            case GL_FLOAT_MAT2x4 = 0x8B66;
            case GL_INT_IMAGE_3D = 0x9059;
            case GL_INT_IMAGE_2D = 0x9058;
            case GL_SAMPLER_2D_RECT = 0x8B63;
            case GL_INT_SAMPLER_2D_RECT = 0x8DCD;
            case GL_DOUBLE_MAT4x2 = 0x8F4D;
            case GL_DOUBLE_MAT4x3 = 0x8F4E;
            case GL_INT = 0x1404;
            case GL_SAMPLER_1D = 0x8B5D;
            case GL_FLOAT_VEC2 = 0x8B50;
            case GL_IMAGE_2D = 0x904D;
            case GL_FLOAT_VEC4 = 0x8B52;
            case GL_FLOAT_VEC3 = 0x8B51;
        }

        [AllowDuplicates]
        public enum ReadBufferMode : uint32 {
            case GL_COLOR_ATTACHMENT15 = 0x8CEF;
            case GL_COLOR_ATTACHMENT14 = 0x8CEE;
            case GL_COLOR_ATTACHMENT0 = 0x8CE0;
            case GL_COLOR_ATTACHMENT11 = 0x8CEB;
            case GL_FRONT = 0x0404;
            case GL_COLOR_ATTACHMENT10 = 0x8CEA;
            case GL_COLOR_ATTACHMENT13 = 0x8CED;
            case GL_FRONT_RIGHT = 0x0401;
            case GL_COLOR_ATTACHMENT12 = 0x8CEC;
            case GL_LEFT = 0x0406;
            case GL_COLOR_ATTACHMENT4 = 0x8CE4;
            case GL_COLOR_ATTACHMENT3 = 0x8CE3;
            case GL_COLOR_ATTACHMENT2 = 0x8CE2;
            case GL_COLOR_ATTACHMENT1 = 0x8CE1;
            case GL_COLOR_ATTACHMENT8 = 0x8CE8;
            case GL_COLOR_ATTACHMENT7 = 0x8CE7;
            case GL_COLOR_ATTACHMENT6 = 0x8CE6;
            case GL_COLOR_ATTACHMENT5 = 0x8CE5;
            case GL_BACK_LEFT = 0x0402;
            case GL_BACK_RIGHT = 0x0403;
            case GL_FRONT_LEFT = 0x0400;
            case GL_BACK = 0x0405;
            case GL_RIGHT = 0x0407;
            case GL_COLOR_ATTACHMENT9 = 0x8CE9;
            case GL_NONE = 0;
        }

        [AllowDuplicates]
        public enum ColorBuffer : uint32 {
            case GL_COLOR_ATTACHMENT15 = 0x8CEF;
            case GL_COLOR_ATTACHMENT14 = 0x8CEE;
            case GL_COLOR_ATTACHMENT17 = 0x8CF1;
            case GL_COLOR_ATTACHMENT16 = 0x8CF0;
            case GL_COLOR_ATTACHMENT0 = 0x8CE0;
            case GL_COLOR_ATTACHMENT11 = 0x8CEB;
            case GL_FRONT = 0x0404;
            case GL_COLOR_ATTACHMENT10 = 0x8CEA;
            case GL_COLOR_ATTACHMENT13 = 0x8CED;
            case GL_FRONT_RIGHT = 0x0401;
            case GL_COLOR_ATTACHMENT12 = 0x8CEC;
            case GL_LEFT = 0x0406;
            case GL_COLOR_ATTACHMENT4 = 0x8CE4;
            case GL_COLOR_ATTACHMENT3 = 0x8CE3;
            case GL_COLOR_ATTACHMENT2 = 0x8CE2;
            case GL_COLOR_ATTACHMENT31 = 0x8CFF;
            case GL_COLOR_ATTACHMENT1 = 0x8CE1;
            case GL_COLOR_ATTACHMENT30 = 0x8CFE;
            case GL_COLOR_ATTACHMENT8 = 0x8CE8;
            case GL_COLOR_ATTACHMENT7 = 0x8CE7;
            case GL_COLOR_ATTACHMENT6 = 0x8CE6;
            case GL_COLOR_ATTACHMENT5 = 0x8CE5;
            case GL_BACK_LEFT = 0x0402;
            case GL_FRONT_AND_BACK = 0x0408;
            case GL_BACK_RIGHT = 0x0403;
            case GL_FRONT_LEFT = 0x0400;
            case GL_COLOR_ATTACHMENT29 = 0x8CFD;
            case GL_COLOR_ATTACHMENT26 = 0x8CFA;
            case GL_COLOR_ATTACHMENT25 = 0x8CF9;
            case GL_COLOR_ATTACHMENT28 = 0x8CFC;
            case GL_COLOR_ATTACHMENT27 = 0x8CFB;
            case GL_COLOR_ATTACHMENT22 = 0x8CF6;
            case GL_BACK = 0x0405;
            case GL_COLOR_ATTACHMENT21 = 0x8CF5;
            case GL_COLOR_ATTACHMENT24 = 0x8CF8;
            case GL_COLOR_ATTACHMENT23 = 0x8CF7;
            case GL_COLOR_ATTACHMENT20 = 0x8CF4;
            case GL_RIGHT = 0x0407;
            case GL_COLOR_ATTACHMENT9 = 0x8CE9;
            case GL_NONE = 0;
            case GL_COLOR_ATTACHMENT19 = 0x8CF3;
            case GL_COLOR_ATTACHMENT18 = 0x8CF2;
        }

        [AllowDuplicates]
        public enum SyncCondition : uint32 {
            case GL_SYNC_GPU_COMMANDS_COMPLETE = 0x9117;
        }

        [AllowDuplicates]
        public enum PixelFormat : uint32 {
            case GL_RG = 0x8227;
            case GL_DEPTH_STENCIL = 0x84F9;
            case GL_ALPHA = 0x1906;
            case GL_RGBA = 0x1908;
            case GL_BGRA = 0x80E1;
            case GL_RGBA_INTEGER = 0x8D99;
            case GL_DEPTH_COMPONENT = 0x1902;
            case GL_RG_INTEGER = 0x8228;
            case GL_UNSIGNED_INT = 0x1405;
            case GL_BGRA_INTEGER = 0x8D9B;
            case GL_BLUE = 0x1905;
            case GL_RGB = 0x1907;
            case GL_BGR = 0x80E0;
            case GL_GREEN = 0x1904;
            case GL_RED = 0x1903;
            case GL_GREEN_INTEGER = 0x8D95;
            case GL_RED_INTEGER = 0x8D94;
            case GL_BGR_INTEGER = 0x8D9A;
            case GL_STENCIL_INDEX = 0x1901;
            case GL_RGB_INTEGER = 0x8D98;
            case GL_UNSIGNED_SHORT = 0x1403;
            case GL_BLUE_INTEGER = 0x8D96;
        }

        [AllowDuplicates]
        public enum VertexBufferObjectUsage : uint32 {
            case GL_STATIC_COPY = 0x88E6;
            case GL_STATIC_DRAW = 0x88E4;
            case GL_STREAM_READ = 0x88E1;
            case GL_DYNAMIC_DRAW = 0x88E8;
            case GL_DYNAMIC_READ = 0x88E9;
            case GL_DYNAMIC_COPY = 0x88EA;
            case GL_STATIC_READ = 0x88E5;
            case GL_STREAM_DRAW = 0x88E0;
            case GL_STREAM_COPY = 0x88E2;
        }

        [AllowDuplicates]
        public enum InternalFormatPName : uint32 {
            case GL_TEXTURE_COMPRESSED_BLOCK_HEIGHT = 0x82B2;
            case GL_READ_PIXELS_TYPE = 0x828E;
            case GL_TEXTURE_GATHER = 0x82A2;
            case GL_INTERNALFORMAT_RED_TYPE = 0x8278;
            case GL_INTERNALFORMAT_BLUE_SIZE = 0x8273;
            case GL_IMAGE_PIXEL_TYPE = 0x82AA;
            case GL_INTERNALFORMAT_ALPHA_TYPE = 0x827B;
            case GL_FRAGMENT_TEXTURE = 0x829F;
            case GL_STENCIL_RENDERABLE = 0x8288;
            case GL_SHADER_IMAGE_ATOMIC = 0x82A6;
            case GL_TESS_CONTROL_TEXTURE = 0x829C;
            case GL_MAX_HEIGHT = 0x827F;
            case GL_DEPTH_COMPONENTS = 0x8284;
            case GL_TEXTURE_VIEW = 0x82B5;
            case GL_MAX_LAYERS = 0x8281;
            case GL_TEXTURE_IMAGE_TYPE = 0x8290;
            case GL_STENCIL_COMPONENTS = 0x8285;
            case GL_DEPTH_RENDERABLE = 0x8287;
            case GL_SIMULTANEOUS_TEXTURE_AND_DEPTH_WRITE = 0x82AE;
            case GL_COLOR_RENDERABLE = 0x8286;
            case GL_INTERNALFORMAT_GREEN_SIZE = 0x8272;
            case GL_VIEW_COMPATIBILITY_CLASS = 0x82B6;
            case GL_TESS_EVALUATION_TEXTURE = 0x829D;
            case GL_READ_PIXELS = 0x828C;
            case GL_FRAMEBUFFER_RENDERABLE = 0x8289;
            case GL_TEXTURE_GATHER_SHADOW = 0x82A3;
            case GL_INTERNALFORMAT_SUPPORTED = 0x826F;
            case GL_NUM_SAMPLE_COUNTS = 0x9380;
            case GL_INTERNALFORMAT_STENCIL_TYPE = 0x827D;
            case GL_INTERNALFORMAT_DEPTH_TYPE = 0x827C;
            case GL_SHADER_IMAGE_LOAD = 0x82A4;
            case GL_SHADER_IMAGE_STORE = 0x82A5;
            case GL_IMAGE_FORMAT_COMPATIBILITY_TYPE = 0x90C7;
            case GL_TEXTURE_IMAGE_FORMAT = 0x828F;
            case GL_SAMPLES = 0x80A9;
            case GL_FRAMEBUFFER_BLEND = 0x828B;
            case GL_VERTEX_TEXTURE = 0x829B;
            case GL_MAX_DEPTH = 0x8280;
            case GL_MAX_WIDTH = 0x827E;
            case GL_SIMULTANEOUS_TEXTURE_AND_DEPTH_TEST = 0x82AC;
            case GL_INTERNALFORMAT_PREFERRED = 0x8270;
            case GL_GET_TEXTURE_IMAGE_FORMAT = 0x8291;
            case GL_FILTER = 0x829A;
            case GL_INTERNALFORMAT_ALPHA_SIZE = 0x8274;
            case GL_MAX_COMBINED_DIMENSIONS = 0x8282;
            case GL_TEXTURE_COMPRESSED_BLOCK_SIZE = 0x82B3;
            case GL_TEXTURE_SHADOW = 0x82A1;
            case GL_AUTO_GENERATE_MIPMAP = 0x8295;
            case GL_COMPUTE_TEXTURE = 0x82A0;
            case GL_COLOR_ENCODING = 0x8296;
            case GL_IMAGE_PIXEL_FORMAT = 0x82A9;
            case GL_INTERNALFORMAT_BLUE_TYPE = 0x827A;
            case GL_SRGB_WRITE = 0x8298;
            case GL_INTERNALFORMAT_GREEN_TYPE = 0x8279;
            case GL_FRAMEBUFFER_RENDERABLE_LAYERED = 0x828A;
            case GL_TEXTURE_COMPRESSED = 0x86A1;
            case GL_SIMULTANEOUS_TEXTURE_AND_STENCIL_TEST = 0x82AD;
            case GL_INTERNALFORMAT_SHARED_SIZE = 0x8277;
            case GL_GEOMETRY_TEXTURE = 0x829E;
            case GL_COLOR_COMPONENTS = 0x8283;
            case GL_INTERNALFORMAT_STENCIL_SIZE = 0x8276;
            case GL_MIPMAP = 0x8293;
            case GL_IMAGE_COMPATIBILITY_CLASS = 0x82A8;
            case GL_INTERNALFORMAT_DEPTH_SIZE = 0x8275;
            case GL_CLEAR_BUFFER = 0x82B4;
            case GL_CLEAR_TEXTURE = 0x9365;
            case GL_READ_PIXELS_FORMAT = 0x828D;
            case GL_SRGB_READ = 0x8297;
            case GL_SIMULTANEOUS_TEXTURE_AND_STENCIL_WRITE = 0x82AF;
            case GL_TEXTURE_COMPRESSED_BLOCK_WIDTH = 0x82B1;
            case GL_GET_TEXTURE_IMAGE_TYPE = 0x8292;
            case GL_INTERNALFORMAT_RED_SIZE = 0x8271;
            case GL_IMAGE_TEXEL_SIZE = 0x82A7;
        }

        [AllowDuplicates]
        public enum SecondaryColorPointerTypeIBM : uint32 {
            case GL_FLOAT = 0x1406;
            case GL_DOUBLE = 0x140A;
            case GL_INT = 0x1404;
            case GL_SHORT = 0x1402;
        }

        [AllowDuplicates]
        public enum SyncBehaviorFlags : uint32 {
            case GL_NONE = 0;
        }

        [AllowDuplicates]
        public enum ProgramInterfacePName : uint32 {
            case GL_MAX_NUM_ACTIVE_VARIABLES = 0x92F7;
            case GL_MAX_NUM_COMPATIBLE_SUBROUTINES = 0x92F8;
            case GL_MAX_NAME_LENGTH = 0x92F6;
            case GL_ACTIVE_RESOURCES = 0x92F5;
        }

        [AllowDuplicates]
        public enum MatrixMode : uint32 {
            case GL_TEXTURE = 0x1702;
        }

        [AllowDuplicates]
        public enum BufferStorageMask : uint32 {
            case GL_MAP_COHERENT_BIT = 0x0080;
            case GL_CLIENT_STORAGE_BIT = 0x0200;
            case GL_DYNAMIC_STORAGE_BIT = 0x0100;
            case GL_MAP_PERSISTENT_BIT = 0x0040;
            case GL_MAP_WRITE_BIT = 0x0002;
            case GL_MAP_READ_BIT = 0x0001;
        }

        [AllowDuplicates]
        public enum SyncStatus : uint32 {
            case GL_TIMEOUT_EXPIRED = 0x911B;
            case GL_CONDITION_SATISFIED = 0x911C;
            case GL_ALREADY_SIGNALED = 0x911A;
            case GL_WAIT_FAILED = 0x911D;
        }

        [AllowDuplicates]
        public enum HintTarget : uint32 {
            case GL_LINE_SMOOTH_HINT = 0x0C52;
            case GL_TEXTURE_COMPRESSION_HINT = 0x84EF;
            case GL_PROGRAM_BINARY_RETRIEVABLE_HINT = 0x8257;
            case GL_FRAGMENT_SHADER_DERIVATIVE_HINT = 0x8B8B;
            case GL_POLYGON_SMOOTH_HINT = 0x0C53;
        }

        [AllowDuplicates]
        public enum ProgramInterface : uint32 {
            case GL_COMPUTE_SUBROUTINE_UNIFORM = 0x92F3;
            case GL_PROGRAM_OUTPUT = 0x92E4;
            case GL_SHADER_STORAGE_BLOCK = 0x92E6;
            case GL_VERTEX_SUBROUTINE = 0x92E8;
            case GL_TESS_EVALUATION_SUBROUTINE = 0x92EA;
            case GL_TESS_EVALUATION_SUBROUTINE_UNIFORM = 0x92F0;
            case GL_FRAGMENT_SUBROUTINE_UNIFORM = 0x92F2;
            case GL_UNIFORM = 0x92E1;
            case GL_TESS_CONTROL_SUBROUTINE_UNIFORM = 0x92EF;
            case GL_TRANSFORM_FEEDBACK_BUFFER = 0x8C8E;
            case GL_FRAGMENT_SUBROUTINE = 0x92EC;
            case GL_COMPUTE_SUBROUTINE = 0x92ED;
            case GL_TRANSFORM_FEEDBACK_VARYING = 0x92F4;
            case GL_VERTEX_SUBROUTINE_UNIFORM = 0x92EE;
            case GL_PROGRAM_INPUT = 0x92E3;
            case GL_GEOMETRY_SUBROUTINE_UNIFORM = 0x92F1;
            case GL_BUFFER_VARIABLE = 0x92E5;
            case GL_UNIFORM_BLOCK = 0x92E2;
            case GL_TESS_CONTROL_SUBROUTINE = 0x92E9;
            case GL_GEOMETRY_SUBROUTINE = 0x92EB;
        }

        [AllowDuplicates]
        public enum PointParameterNameSGIS : uint32 {
            case GL_POINT_FADE_THRESHOLD_SIZE = 0x8128;
        }

        [AllowDuplicates]
        public enum GlslTypeToken : uint32 {
            case GL_IMAGE_1D_ARRAY = 0x9052;
            case GL_IMAGE_3D = 0x904E;
            case GL_SAMPLER_2D_MULTISAMPLE_ARRAY = 0x910B;
            case GL_UNSIGNED_INT_SAMPLER_2D = 0x8DD2;
            case GL_INT_IMAGE_2D_RECT = 0x905A;
            case GL_UNSIGNED_INT_VEC4 = 0x8DC8;
            case GL_UNSIGNED_INT = 0x1405;
            case GL_INT_SAMPLER_1D_ARRAY = 0x8DCE;
            case GL_INT_SAMPLER_2D_ARRAY = 0x8DCF;
            case GL_INT_IMAGE_CUBE = 0x905B;
            case GL_SAMPLER_2D_ARRAY = 0x8DC1;
            case GL_SAMPLER_1D_ARRAY = 0x8DC0;
            case GL_IMAGE_2D_ARRAY = 0x9053;
            case GL_IMAGE_2D_MULTISAMPLE_ARRAY = 0x9056;
            case GL_INT_SAMPLER_CUBE_MAP_ARRAY = 0x900E;
            case GL_INT_SAMPLER_BUFFER = 0x8DD0;
            case GL_UNSIGNED_INT_IMAGE_1D_ARRAY = 0x9068;
            case GL_FLOAT_MAT3x4 = 0x8B68;
            case GL_UNSIGNED_INT_SAMPLER_1D = 0x8DD1;
            case GL_INT_IMAGE_2D_ARRAY = 0x905E;
            case GL_FLOAT_MAT3x2 = 0x8B67;
            case GL_IMAGE_BUFFER = 0x9051;
            case GL_BOOL_VEC4 = 0x8B59;
            case GL_BOOL_VEC3 = 0x8B58;
            case GL_INT_IMAGE_2D_MULTISAMPLE_ARRAY = 0x9061;
            case GL_UNSIGNED_INT_IMAGE_BUFFER = 0x9067;
            case GL_BOOL_VEC2 = 0x8B57;
            case GL_UNSIGNED_INT_VEC3 = 0x8DC7;
            case GL_UNSIGNED_INT_VEC2 = 0x8DC6;
            case GL_SAMPLER_CUBE_SHADOW = 0x8DC5;
            case GL_SAMPLER_BUFFER = 0x8DC2;
            case GL_UNSIGNED_INT_IMAGE_2D_MULTISAMPLE = 0x906B;
            case GL_UNSIGNED_INT_IMAGE_2D = 0x9063;
            case GL_UNSIGNED_INT_IMAGE_CUBE_MAP_ARRAY = 0x906A;
            case GL_UNSIGNED_INT_SAMPLER_BUFFER = 0x8DD8;
            case GL_UNSIGNED_INT_IMAGE_2D_MULTISAMPLE_ARRAY = 0x906C;
            case GL_FLOAT_MAT4 = 0x8B5C;
            case GL_FLOAT_MAT3 = 0x8B5B;
            case GL_FLOAT_MAT2 = 0x8B5A;
            case GL_UNSIGNED_INT_SAMPLER_2D_RECT = 0x8DD5;
            case GL_UNSIGNED_INT_SAMPLER_2D_MULTISAMPLE = 0x910A;
            case GL_SAMPLER_2D_ARRAY_SHADOW = 0x8DC4;
            case GL_INT_SAMPLER_2D_MULTISAMPLE_ARRAY = 0x910C;
            case GL_UNSIGNED_INT_SAMPLER_2D_ARRAY = 0x8DD7;
            case GL_IMAGE_2D_RECT = 0x904F;
            case GL_UNSIGNED_INT_SAMPLER_CUBE_MAP_ARRAY = 0x900F;
            case GL_UNSIGNED_INT_IMAGE_2D_RECT = 0x9065;
            case GL_INT_IMAGE_BUFFER = 0x905C;
            case GL_INT_SAMPLER_1D = 0x8DC9;
            case GL_UNSIGNED_INT_ATOMIC_COUNTER = 0x92DB;
            case GL_SAMPLER_1D_SHADOW = 0x8B61;
            case GL_UNSIGNED_INT_IMAGE_1D = 0x9062;
            case GL_UNSIGNED_INT_SAMPLER_3D = 0x8DD3;
            case GL_UNSIGNED_INT_IMAGE_2D_ARRAY = 0x9069;
            case GL_FLOAT_MAT4x3 = 0x8B6A;
            case GL_DOUBLE_VEC4 = 0x8FFE;
            case GL_DOUBLE_VEC3 = 0x8FFD;
            case GL_SAMPLER_2D_MULTISAMPLE = 0x9108;
            case GL_FLOAT_MAT4x2 = 0x8B69;
            case GL_DOUBLE_VEC2 = 0x8FFC;
            case GL_INT_SAMPLER_CUBE = 0x8DCC;
            case GL_INT_IMAGE_2D_MULTISAMPLE = 0x9060;
            case GL_INT_IMAGE_1D_ARRAY = 0x905D;
            case GL_INT_SAMPLER_2D_MULTISAMPLE = 0x9109;
            case GL_INT_VEC4 = 0x8B55;
            case GL_INT_VEC2 = 0x8B53;
            case GL_INT_VEC3 = 0x8B54;
            case GL_SAMPLER_CUBE_MAP_ARRAY_SHADOW = 0x900D;
            case GL_FLOAT = 0x1406;
            case GL_SAMPLER_2D_RECT_SHADOW = 0x8B64;
            case GL_INT_SAMPLER_3D = 0x8DCB;
            case GL_UNSIGNED_INT_IMAGE_CUBE = 0x9066;
            case GL_SAMPLER_2D_SHADOW = 0x8B62;
            case GL_DOUBLE = 0x140A;
            case GL_UNSIGNED_INT_IMAGE_3D = 0x9064;
            case GL_SAMPLER_3D = 0x8B5F;
            case GL_DOUBLE_MAT4 = 0x8F48;
            case GL_INT_SAMPLER_2D = 0x8DCA;
            case GL_SAMPLER_1D_ARRAY_SHADOW = 0x8DC3;
            case GL_UNSIGNED_INT_SAMPLER_2D_MULTISAMPLE_ARRAY = 0x910D;
            case GL_DOUBLE_MAT3 = 0x8F47;
            case GL_DOUBLE_MAT2 = 0x8F46;
            case GL_IMAGE_CUBE_MAP_ARRAY = 0x9054;
            case GL_INT_IMAGE_CUBE_MAP_ARRAY = 0x905F;
            case GL_UNSIGNED_INT_SAMPLER_CUBE = 0x8DD4;
            case GL_IMAGE_CUBE = 0x9050;
            case GL_SAMPLER_2D = 0x8B5E;
            case GL_INT_IMAGE_1D = 0x9057;
            case GL_SAMPLER_CUBE_MAP_ARRAY = 0x900C;
            case GL_UNSIGNED_INT_SAMPLER_1D_ARRAY = 0x8DD6;
            case GL_IMAGE_2D_MULTISAMPLE = 0x9055;
            case GL_IMAGE_1D = 0x904C;
            case GL_BOOL = 0x8B56;
            case GL_SAMPLER_CUBE = 0x8B60;
            case GL_FLOAT_MAT2x3 = 0x8B65;
            case GL_FLOAT_MAT2x4 = 0x8B66;
            case GL_INT_IMAGE_3D = 0x9059;
            case GL_INT_IMAGE_2D = 0x9058;
            case GL_SAMPLER_2D_RECT = 0x8B63;
            case GL_INT_SAMPLER_2D_RECT = 0x8DCD;
            case GL_INT = 0x1404;
            case GL_SAMPLER_1D = 0x8B5D;
            case GL_FLOAT_VEC2 = 0x8B50;
            case GL_IMAGE_2D = 0x904D;
            case GL_FLOAT_VEC4 = 0x8B52;
            case GL_FLOAT_VEC3 = 0x8B51;
        }

        [AllowDuplicates]
        public enum DepthFunction : uint32 {
            case GL_EQUAL = 0x0202;
            case GL_GREATER = 0x0204;
            case GL_LEQUAL = 0x0203;
            case GL_NEVER = 0x0200;
            case GL_GEQUAL = 0x0206;
            case GL_LESS = 0x0201;
            case GL_NOTEQUAL = 0x0205;
            case GL_ALWAYS = 0x0207;
        }

        [AllowDuplicates]
        public enum PathTransformType : uint32 {
            case GL_NONE = 0;
        }

        [AllowDuplicates]
        public enum TextureWrapMode : uint32 {
            case GL_LINEAR_MIPMAP_LINEAR = 0x2703;
            case GL_CLAMP_TO_BORDER = 0x812D;
            case GL_REPEAT = 0x2901;
            case GL_MIRROR_CLAMP_TO_EDGE = 0x8743;
            case GL_MIRRORED_REPEAT = 0x8370;
            case GL_CLAMP_TO_EDGE = 0x812F;
        }

        [AllowDuplicates]
        public enum InternalFormat : uint32 {
            case GL_RGB10_A2UI = 0x906F;
            case GL_COMPRESSED_SRGB8_ALPHA8_ETC2_EAC = 0x9279;
            case GL_COMPRESSED_RGB = 0x84ED;
            case GL_R8I = 0x8231;
            case GL_STENCIL_INDEX4 = 0x8D47;
            case GL_RG8UI = 0x8238;
            case GL_STENCIL_INDEX1 = 0x8D46;
            case GL_RG32F = 0x8230;
            case GL_RG32I = 0x823B;
            case GL_STENCIL_INDEX = 0x1901;
            case GL_RG16I = 0x8239;
            case GL_R16 = 0x822A;
            case GL_COMPRESSED_RED_RGTC1 = 0x8DBB;
            case GL_RG16F = 0x822F;
            case GL_RGBA16UI = 0x8D76;
            case GL_RGBA8 = 0x8058;
            case GL_RGBA4 = 0x8056;
            case GL_RGBA2 = 0x8055;
            case GL_SRGB8_ALPHA8 = 0x8C43;
            case GL_RGB8I = 0x8D8F;
            case GL_COMPRESSED_RG_RGTC2 = 0x8DBD;
            case GL_STENCIL_INDEX8 = 0x8D48;
            case GL_R32UI = 0x8236;
            case GL_DEPTH_COMPONENT32 = 0x81A7;
            case GL_RGBA16_SNORM = 0x8F9B;
            case GL_RG16_SNORM = 0x8F99;
            case GL_RGB16 = 0x8054;
            case GL_RGB12 = 0x8053;
            case GL_RGB10 = 0x8052;
            case GL_R3_G3_B2 = 0x2A10;
            case GL_R11F_G11F_B10F = 0x8C3A;
            case GL_COMPRESSED_SIGNED_R11_EAC = 0x9271;
            case GL_COMPRESSED_RG = 0x8226;
            case GL_COMPRESSED_RGB8_ETC2 = 0x9274;
            case GL_RGBA8_SNORM = 0x8F97;
            case GL_RGBA16I = 0x8D88;
            case GL_RGBA16F = 0x881A;
            case GL_RGBA8UI = 0x8D7C;
            case GL_RGBA32I = 0x8D82;
            case GL_COMPRESSED_RGB_BPTC_UNSIGNED_FLOAT = 0x8E8F;
            case GL_COMPRESSED_RG11_EAC = 0x9272;
            case GL_COMPRESSED_RGBA = 0x84EE;
            case GL_RGB16_SNORM = 0x8F9A;
            case GL_RGBA32F = 0x8814;
            case GL_DEPTH24_STENCIL8 = 0x88F0;
            case GL_RGBA32UI = 0x8D70;
            case GL_DEPTH_COMPONENT = 0x1902;
            case GL_R16UI = 0x8234;
            case GL_COMPRESSED_RGBA8_ETC2_EAC = 0x9278;
            case GL_SRGB = 0x8C40;
            case GL_SRGB_ALPHA = 0x8C42;
            case GL_COMPRESSED_RGBA_BPTC_UNORM = 0x8E8C;
            case GL_SRGB8 = 0x8C41;
            case GL_COMPRESSED_SRGB8_PUNCHTHROUGH_ALPHA1_ETC2 = 0x9277;
            case GL_RGB16UI = 0x8D77;
            case GL_RED = 0x1903;
            case GL_COMPRESSED_SRGB_ALPHA_BPTC_UNORM = 0x8E8D;
            case GL_COMPRESSED_SRGB = 0x8C48;
            case GL_COMPRESSED_SIGNED_RED_RGTC1 = 0x8DBC;
            case GL_R8_SNORM = 0x8F94;
            case GL_RGB8UI = 0x8D7D;
            case GL_R16F = 0x822D;
            case GL_R32F = 0x822E;
            case GL_RGBA = 0x1908;
            case GL_RGB8_SNORM = 0x8F96;
            case GL_R16I = 0x8233;
            case GL_DEPTH32F_STENCIL8 = 0x8CAD;
            case GL_RGB5 = 0x8050;
            case GL_RGB16I = 0x8D89;
            case GL_RGB4 = 0x804F;
            case GL_RGB32F = 0x8815;
            case GL_COMPRESSED_R11_EAC = 0x9270;
            case GL_DEPTH_COMPONENT32F = 0x8CAC;
            case GL_RGB8 = 0x8051;
            case GL_RGB32I = 0x8D83;
            case GL_COMPRESSED_SRGB8_ETC2 = 0x9275;
            case GL_RG32UI = 0x823C;
            case GL_RGB16F = 0x881B;
            case GL_R32I = 0x8235;
            case GL_RGB10_A2 = 0x8059;
            case GL_R16_SNORM = 0x8F98;
            case GL_R8UI = 0x8232;
            case GL_RG = 0x8227;
            case GL_DEPTH_STENCIL = 0x84F9;
            case GL_COMPRESSED_RGB8_PUNCHTHROUGH_ALPHA1_ETC2 = 0x9276;
            case GL_COMPRESSED_SRGB_ALPHA = 0x8C49;
            case GL_RG8 = 0x822B;
            case GL_RGB9_E5 = 0x8C3D;
            case GL_RGBA16 = 0x805B;
            case GL_RG8I = 0x8237;
            case GL_RGB5_A1 = 0x8057;
            case GL_R8 = 0x8229;
            case GL_COMPRESSED_RED = 0x8225;
            case GL_RGB = 0x1907;
            case GL_RGBA12 = 0x805A;
            case GL_COMPRESSED_SIGNED_RG11_EAC = 0x9273;
            case GL_DEPTH_COMPONENT24 = 0x81A6;
            case GL_RG16 = 0x822C;
            case GL_RG8_SNORM = 0x8F95;
            case GL_RGB32UI = 0x8D71;
            case GL_COMPRESSED_SIGNED_RG_RGTC2 = 0x8DBE;
            case GL_RGBA8I = 0x8D8E;
            case GL_STENCIL_INDEX16 = 0x8D49;
            case GL_COMPRESSED_RGB_BPTC_SIGNED_FLOAT = 0x8E8E;
            case GL_RG16UI = 0x823A;
            case GL_DEPTH_COMPONENT16 = 0x81A5;
        }

        [AllowDuplicates]
        public enum DebugType : uint32 {
            case GL_DEBUG_TYPE_PUSH_GROUP = 0x8269;
            case GL_DEBUG_TYPE_MARKER = 0x8268;
            case GL_DEBUG_TYPE_ERROR = 0x824C;
            case GL_DEBUG_TYPE_PERFORMANCE = 0x8250;
            case GL_DEBUG_TYPE_PORTABILITY = 0x824F;
            case GL_DONT_CARE = 0x1100;
            case GL_DEBUG_TYPE_DEPRECATED_BEHAVIOR = 0x824D;
            case GL_DEBUG_TYPE_UNDEFINED_BEHAVIOR = 0x824E;
            case GL_DEBUG_TYPE_OTHER = 0x8251;
            case GL_DEBUG_TYPE_POP_GROUP = 0x826A;
        }

        [AllowDuplicates]
        public enum QueryTarget : uint32 {
            case GL_ANY_SAMPLES_PASSED = 0x8C2F;
            case GL_ANY_SAMPLES_PASSED_CONSERVATIVE = 0x8D6A;
            case GL_PRIMITIVES_GENERATED = 0x8C87;
            case GL_TRANSFORM_FEEDBACK_PRIMITIVES_WRITTEN = 0x8C88;
            case GL_TIME_ELAPSED = 0x88BF;
            case GL_SAMPLES_PASSED = 0x8914;
        }

        [AllowDuplicates]
        public enum GetMultisamplePNameNV : uint32 {
            case GL_SAMPLE_POSITION = 0x8E50;
        }

        [AllowDuplicates]
        public enum IndexPointerType : uint32 {
            case GL_FLOAT = 0x1406;
            case GL_DOUBLE = 0x140A;
            case GL_INT = 0x1404;
            case GL_SHORT = 0x1402;
        }

        [AllowDuplicates]
        public enum VertexPointerType : uint32 {
            case GL_FLOAT = 0x1406;
            case GL_DOUBLE = 0x140A;
            case GL_INT = 0x1404;
            case GL_SHORT = 0x1402;
        }

        [AllowDuplicates]
        public enum SizedInternalFormat : uint32 {
            case GL_RGB10_A2UI = 0x906F;
            case GL_COMPRESSED_RGBA_BPTC_UNORM = 0x8E8C;
            case GL_SRGB8 = 0x8C41;
            case GL_COMPRESSED_SRGB8_ALPHA8_ETC2_EAC = 0x9279;
            case GL_R8I = 0x8231;
            case GL_STENCIL_INDEX4 = 0x8D47;
            case GL_COMPRESSED_SRGB8_PUNCHTHROUGH_ALPHA1_ETC2 = 0x9277;
            case GL_RG8UI = 0x8238;
            case GL_STENCIL_INDEX1 = 0x8D46;
            case GL_RGB16UI = 0x8D77;
            case GL_COMPRESSED_SRGB_ALPHA_BPTC_UNORM = 0x8E8D;
            case GL_RG32F = 0x8230;
            case GL_RG32I = 0x823B;
            case GL_RG16I = 0x8239;
            case GL_R16 = 0x822A;
            case GL_COMPRESSED_RED_RGTC1 = 0x8DBB;
            case GL_RG16F = 0x822F;
            case GL_COMPRESSED_SIGNED_RED_RGTC1 = 0x8DBC;
            case GL_R8_SNORM = 0x8F94;
            case GL_RGBA16UI = 0x8D76;
            case GL_RGB8UI = 0x8D7D;
            case GL_R16F = 0x822D;
            case GL_RGBA8 = 0x8058;
            case GL_R32F = 0x822E;
            case GL_RGB8_SNORM = 0x8F96;
            case GL_R16I = 0x8233;
            case GL_DEPTH32F_STENCIL8 = 0x8CAD;
            case GL_RGBA4 = 0x8056;
            case GL_RGB5 = 0x8050;
            case GL_RGB16I = 0x8D89;
            case GL_RGB4 = 0x804F;
            case GL_RGBA2 = 0x8055;
            case GL_SRGB8_ALPHA8 = 0x8C43;
            case GL_RGB8I = 0x8D8F;
            case GL_COMPRESSED_RG_RGTC2 = 0x8DBD;
            case GL_RGB32F = 0x8815;
            case GL_STENCIL_INDEX8 = 0x8D48;
            case GL_COMPRESSED_R11_EAC = 0x9270;
            case GL_DEPTH_COMPONENT32F = 0x8CAC;
            case GL_RGB8 = 0x8051;
            case GL_R32UI = 0x8236;
            case GL_RGB32I = 0x8D83;
            case GL_DEPTH_COMPONENT32 = 0x81A7;
            case GL_RGBA16_SNORM = 0x8F9B;
            case GL_COMPRESSED_SRGB8_ETC2 = 0x9275;
            case GL_RG32UI = 0x823C;
            case GL_RG16_SNORM = 0x8F99;
            case GL_RGB16 = 0x8054;
            case GL_RGB16F = 0x881B;
            case GL_R32I = 0x8235;
            case GL_RGB12 = 0x8053;
            case GL_RGB10_A2 = 0x8059;
            case GL_RGB10 = 0x8052;
            case GL_R16_SNORM = 0x8F98;
            case GL_R8UI = 0x8232;
            case GL_R3_G3_B2 = 0x2A10;
            case GL_R11F_G11F_B10F = 0x8C3A;
            case GL_COMPRESSED_RGB8_PUNCHTHROUGH_ALPHA1_ETC2 = 0x9276;
            case GL_COMPRESSED_SIGNED_R11_EAC = 0x9271;
            case GL_RG8 = 0x822B;
            case GL_RGB9_E5 = 0x8C3D;
            case GL_COMPRESSED_RGB8_ETC2 = 0x9274;
            case GL_RGBA16 = 0x805B;
            case GL_RG8I = 0x8237;
            case GL_RGB5_A1 = 0x8057;
            case GL_R8 = 0x8229;
            case GL_RGBA8_SNORM = 0x8F97;
            case GL_RGBA16I = 0x8D88;
            case GL_RGBA16F = 0x881A;
            case GL_RGBA12 = 0x805A;
            case GL_RGBA8UI = 0x8D7C;
            case GL_RGBA32I = 0x8D82;
            case GL_COMPRESSED_RGB_BPTC_UNSIGNED_FLOAT = 0x8E8F;
            case GL_COMPRESSED_RG11_EAC = 0x9272;
            case GL_COMPRESSED_SIGNED_RG11_EAC = 0x9273;
            case GL_DEPTH_COMPONENT24 = 0x81A6;
            case GL_RGB16_SNORM = 0x8F9A;
            case GL_RG16 = 0x822C;
            case GL_RGBA32F = 0x8814;
            case GL_RG8_SNORM = 0x8F95;
            case GL_DEPTH24_STENCIL8 = 0x88F0;
            case GL_RGB32UI = 0x8D71;
            case GL_COMPRESSED_SIGNED_RG_RGTC2 = 0x8DBE;
            case GL_RGBA32UI = 0x8D70;
            case GL_RGBA8I = 0x8D8E;
            case GL_R16UI = 0x8234;
            case GL_STENCIL_INDEX16 = 0x8D49;
            case GL_COMPRESSED_RGB_BPTC_SIGNED_FLOAT = 0x8E8E;
            case GL_COMPRESSED_RGBA8_ETC2_EAC = 0x9278;
            case GL_RG16UI = 0x823A;
            case GL_DEPTH_COMPONENT16 = 0x81A5;
        }

        [AllowDuplicates]
        public enum TextureSwizzle : uint32 {
            case GL_BLUE = 0x1905;
            case GL_GREEN = 0x1904;
            case GL_RED = 0x1903;
            case GL_ALPHA = 0x1906;
            case GL_ZERO = 0;
            case GL_ONE = 1;
        }

        [AllowDuplicates]
        public enum StencilFaceDirection : uint32 {
            case GL_FRONT = 0x0404;
            case GL_BACK = 0x0405;
            case GL_FRONT_AND_BACK = 0x0408;
        }

        [AllowDuplicates]
        public enum TextureTarget : uint32 {
            case GL_PROXY_TEXTURE_2D = 0x8064;
            case GL_PROXY_TEXTURE_2D_MULTISAMPLE = 0x9101;
            case GL_TEXTURE_CUBE_MAP_ARRAY = 0x9009;
            case GL_PROXY_TEXTURE_2D_ARRAY = 0x8C1B;
            case GL_PROXY_TEXTURE_1D_ARRAY = 0x8C19;
            case GL_TEXTURE_2D = 0x0DE1;
            case GL_TEXTURE_1D_ARRAY = 0x8C18;
            case GL_PROXY_TEXTURE_CUBE_MAP = 0x851B;
            case GL_TEXTURE_2D_ARRAY = 0x8C1A;
            case GL_TEXTURE_2D_MULTISAMPLE = 0x9100;
            case GL_TEXTURE_CUBE_MAP_POSITIVE_X = 0x8515;
            case GL_TEXTURE_CUBE_MAP_POSITIVE_Y = 0x8517;
            case GL_TEXTURE_CUBE_MAP_POSITIVE_Z = 0x8519;
            case GL_PROXY_TEXTURE_3D = 0x8070;
            case GL_PROXY_TEXTURE_1D = 0x8063;
            case GL_TEXTURE_RECTANGLE = 0x84F5;
            case GL_TEXTURE_CUBE_MAP_NEGATIVE_X = 0x8516;
            case GL_TEXTURE_CUBE_MAP_NEGATIVE_Z = 0x851A;
            case GL_TEXTURE_CUBE_MAP_NEGATIVE_Y = 0x8518;
            case GL_TEXTURE_CUBE_MAP = 0x8513;
            case GL_TEXTURE_3D = 0x806F;
            case GL_TEXTURE_1D = 0x0DE0;
            case GL_TEXTURE_2D_MULTISAMPLE_ARRAY = 0x9102;
            case GL_PROXY_TEXTURE_RECTANGLE = 0x84F7;
            case GL_TEXTURE_BUFFER = 0x8C2A;
            case GL_PROXY_TEXTURE_CUBE_MAP_ARRAY = 0x900B;
            case GL_PROXY_TEXTURE_2D_MULTISAMPLE_ARRAY = 0x9103;
        }

        [AllowDuplicates]
        public enum CheckFramebufferStatusTarget : uint32 {
            case GL_DRAW_FRAMEBUFFER = 0x8CA9;
            case GL_READ_FRAMEBUFFER = 0x8CA8;
            case GL_FRAMEBUFFER = 0x8D40;
        }

        [AllowDuplicates]
        public enum PipelineParameterName : uint32 {
            case GL_VERTEX_SHADER = 0x8B31;
            case GL_GEOMETRY_SHADER = 0x8DD9;
            case GL_INFO_LOG_LENGTH = 0x8B84;
            case GL_TESS_CONTROL_SHADER = 0x8E88;
            case GL_FRAGMENT_SHADER = 0x8B30;
            case GL_TESS_EVALUATION_SHADER = 0x8E87;
            case GL_ACTIVE_PROGRAM = 0x8259;
        }

        [AllowDuplicates]
        public enum TangentPointerTypeEXT : uint32 {
            case GL_FLOAT = 0x1406;
            case GL_DOUBLE = 0x140A;
            case GL_BYTE = 0x1400;
            case GL_INT = 0x1404;
            case GL_SHORT = 0x1402;
        }

        [AllowDuplicates]
        public enum SpecialNumbers : uint64 {
            case GL_INVALID_INDEX = 0xFFFFFFFF;
            case GL_NO_ERROR = 0;
            case GL_TRUE = 1;
            case GL_NONE = 0;
            case GL_FALSE = 0;
            case GL_ZERO = 0;
            case GL_ONE = 1;
            case GL_TIMEOUT_IGNORED = 0xFFFFFFFFFFFFFFFF;
        }

        [AllowDuplicates]
        public enum UniformPName : uint32 {
            case GL_UNIFORM_SIZE = 0x8A38;
            case GL_UNIFORM_ATOMIC_COUNTER_BUFFER_INDEX = 0x92DA;
            case GL_UNIFORM_MATRIX_STRIDE = 0x8A3D;
            case GL_UNIFORM_TYPE = 0x8A37;
            case GL_UNIFORM_OFFSET = 0x8A3B;
            case GL_UNIFORM_ARRAY_STRIDE = 0x8A3C;
            case GL_UNIFORM_IS_ROW_MAJOR = 0x8A3E;
            case GL_UNIFORM_NAME_LENGTH = 0x8A39;
            case GL_UNIFORM_BLOCK_INDEX = 0x8A3A;
        }

        [AllowDuplicates]
        public enum BufferStorageTarget : uint32 {
            case GL_UNIFORM_BUFFER = 0x8A11;
            case GL_COPY_WRITE_BUFFER = 0x8F37;
            case GL_QUERY_BUFFER = 0x9192;
            case GL_DISPATCH_INDIRECT_BUFFER = 0x90EE;
            case GL_TRANSFORM_FEEDBACK_BUFFER = 0x8C8E;
            case GL_DRAW_INDIRECT_BUFFER = 0x8F3F;
            case GL_PIXEL_UNPACK_BUFFER = 0x88EC;
            case GL_ELEMENT_ARRAY_BUFFER = 0x8893;
            case GL_PIXEL_PACK_BUFFER = 0x88EB;
            case GL_TEXTURE_BUFFER = 0x8C2A;
            case GL_COPY_READ_BUFFER = 0x8F36;
            case GL_ATOMIC_COUNTER_BUFFER = 0x92C0;
            case GL_ARRAY_BUFFER = 0x8892;
            case GL_SHADER_STORAGE_BUFFER = 0x90D2;
        }

        [AllowDuplicates]
        public enum TextureMinFilter : uint32 {
            case GL_LINEAR_MIPMAP_LINEAR = 0x2703;
            case GL_LINEAR = 0x2601;
            case GL_NEAREST_MIPMAP_LINEAR = 0x2702;
            case GL_LINEAR_MIPMAP_NEAREST = 0x2701;
            case GL_NEAREST = 0x2600;
            case GL_NEAREST_MIPMAP_NEAREST = 0x2700;
        }

        [AllowDuplicates]
        public enum GetFramebufferParameter : uint32 {
            case GL_FRAMEBUFFER_DEFAULT_WIDTH = 0x9310;
            case GL_FRAMEBUFFER_DEFAULT_HEIGHT = 0x9311;
            case GL_FRAMEBUFFER_DEFAULT_FIXED_SAMPLE_LOCATIONS = 0x9314;
            case GL_STEREO = 0x0C33;
            case GL_SAMPLE_BUFFERS = 0x80A8;
            case GL_FRAMEBUFFER_DEFAULT_LAYERS = 0x9312;
            case GL_FRAMEBUFFER_DEFAULT_SAMPLES = 0x9313;
            case GL_DOUBLEBUFFER = 0x0C32;
            case GL_IMPLEMENTATION_COLOR_READ_FORMAT = 0x8B9B;
            case GL_SAMPLES = 0x80A9;
            case GL_IMPLEMENTATION_COLOR_READ_TYPE = 0x8B9A;
        }

        [AllowDuplicates]
        public enum BlendEquationModeEXT : uint32 {
            case GL_MAX = 0x8008;
            case GL_FUNC_ADD = 0x8006;
            case GL_MIN = 0x8007;
            case GL_FUNC_REVERSE_SUBTRACT = 0x800B;
            case GL_FUNC_SUBTRACT = 0x800A;
        }

        [AllowDuplicates]
        public enum ProgramParameterPName : uint32 {
            case GL_PROGRAM_SEPARABLE = 0x8258;
            case GL_PROGRAM_BINARY_RETRIEVABLE_HINT = 0x8257;
        }

        [AllowDuplicates]
        public enum ScalarType : uint32 {
            case GL_UNSIGNED_SHORT = 0x1403;
            case GL_UNSIGNED_BYTE = 0x1401;
            case GL_UNSIGNED_INT = 0x1405;
        }

        [AllowDuplicates]
        public enum DrawBufferMode : uint32 {
            case GL_COLOR_ATTACHMENT15 = 0x8CEF;
            case GL_COLOR_ATTACHMENT14 = 0x8CEE;
            case GL_COLOR_ATTACHMENT17 = 0x8CF1;
            case GL_COLOR_ATTACHMENT16 = 0x8CF0;
            case GL_COLOR_ATTACHMENT0 = 0x8CE0;
            case GL_COLOR_ATTACHMENT11 = 0x8CEB;
            case GL_FRONT = 0x0404;
            case GL_COLOR_ATTACHMENT10 = 0x8CEA;
            case GL_COLOR_ATTACHMENT13 = 0x8CED;
            case GL_FRONT_RIGHT = 0x0401;
            case GL_COLOR_ATTACHMENT12 = 0x8CEC;
            case GL_LEFT = 0x0406;
            case GL_COLOR_ATTACHMENT4 = 0x8CE4;
            case GL_COLOR_ATTACHMENT3 = 0x8CE3;
            case GL_COLOR_ATTACHMENT2 = 0x8CE2;
            case GL_COLOR_ATTACHMENT31 = 0x8CFF;
            case GL_COLOR_ATTACHMENT1 = 0x8CE1;
            case GL_COLOR_ATTACHMENT30 = 0x8CFE;
            case GL_COLOR_ATTACHMENT8 = 0x8CE8;
            case GL_COLOR_ATTACHMENT7 = 0x8CE7;
            case GL_COLOR_ATTACHMENT6 = 0x8CE6;
            case GL_COLOR_ATTACHMENT5 = 0x8CE5;
            case GL_BACK_LEFT = 0x0402;
            case GL_FRONT_AND_BACK = 0x0408;
            case GL_BACK_RIGHT = 0x0403;
            case GL_FRONT_LEFT = 0x0400;
            case GL_COLOR_ATTACHMENT29 = 0x8CFD;
            case GL_COLOR_ATTACHMENT26 = 0x8CFA;
            case GL_COLOR_ATTACHMENT25 = 0x8CF9;
            case GL_COLOR_ATTACHMENT28 = 0x8CFC;
            case GL_COLOR_ATTACHMENT27 = 0x8CFB;
            case GL_COLOR_ATTACHMENT22 = 0x8CF6;
            case GL_BACK = 0x0405;
            case GL_COLOR_ATTACHMENT21 = 0x8CF5;
            case GL_COLOR_ATTACHMENT24 = 0x8CF8;
            case GL_COLOR_ATTACHMENT23 = 0x8CF7;
            case GL_COLOR_ATTACHMENT20 = 0x8CF4;
            case GL_RIGHT = 0x0407;
            case GL_COLOR_ATTACHMENT9 = 0x8CE9;
            case GL_NONE = 0;
            case GL_COLOR_ATTACHMENT19 = 0x8CF3;
            case GL_COLOR_ATTACHMENT18 = 0x8CF2;
        }

        [AllowDuplicates]
        public enum SyncParameterName : uint32 {
            case GL_SYNC_STATUS = 0x9114;
            case GL_SYNC_FLAGS = 0x9115;
            case GL_OBJECT_TYPE = 0x9112;
            case GL_SYNC_CONDITION = 0x9113;
        }

        [AllowDuplicates]
        public enum IndexFunctionEXT : uint32 {
            case GL_EQUAL = 0x0202;
            case GL_GREATER = 0x0204;
            case GL_LEQUAL = 0x0203;
            case GL_NEVER = 0x0200;
            case GL_GEQUAL = 0x0206;
            case GL_LESS = 0x0201;
            case GL_NOTEQUAL = 0x0205;
            case GL_ALWAYS = 0x0207;
        }

        [AllowDuplicates]
        public enum InvalidateFramebufferAttachment : uint32 {
            case GL_COLOR_ATTACHMENT15 = 0x8CEF;
            case GL_DEPTH = 0x1801;
            case GL_COLOR_ATTACHMENT14 = 0x8CEE;
            case GL_COLOR_ATTACHMENT17 = 0x8CF1;
            case GL_COLOR_ATTACHMENT16 = 0x8CF0;
            case GL_COLOR_ATTACHMENT0 = 0x8CE0;
            case GL_COLOR_ATTACHMENT11 = 0x8CEB;
            case GL_COLOR_ATTACHMENT10 = 0x8CEA;
            case GL_COLOR_ATTACHMENT13 = 0x8CED;
            case GL_COLOR_ATTACHMENT12 = 0x8CEC;
            case GL_COLOR_ATTACHMENT4 = 0x8CE4;
            case GL_COLOR_ATTACHMENT3 = 0x8CE3;
            case GL_COLOR_ATTACHMENT2 = 0x8CE2;
            case GL_COLOR_ATTACHMENT31 = 0x8CFF;
            case GL_COLOR_ATTACHMENT1 = 0x8CE1;
            case GL_COLOR_ATTACHMENT30 = 0x8CFE;
            case GL_COLOR_ATTACHMENT8 = 0x8CE8;
            case GL_COLOR_ATTACHMENT7 = 0x8CE7;
            case GL_COLOR_ATTACHMENT6 = 0x8CE6;
            case GL_COLOR_ATTACHMENT5 = 0x8CE5;
            case GL_DEPTH_STENCIL_ATTACHMENT = 0x821A;
            case GL_COLOR = 0x1800;
            case GL_COLOR_ATTACHMENT29 = 0x8CFD;
            case GL_COLOR_ATTACHMENT26 = 0x8CFA;
            case GL_COLOR_ATTACHMENT25 = 0x8CF9;
            case GL_COLOR_ATTACHMENT28 = 0x8CFC;
            case GL_COLOR_ATTACHMENT27 = 0x8CFB;
            case GL_COLOR_ATTACHMENT22 = 0x8CF6;
            case GL_COLOR_ATTACHMENT21 = 0x8CF5;
            case GL_COLOR_ATTACHMENT24 = 0x8CF8;
            case GL_DEPTH_ATTACHMENT = 0x8D00;
            case GL_COLOR_ATTACHMENT23 = 0x8CF7;
            case GL_COLOR_ATTACHMENT20 = 0x8CF4;
            case GL_STENCIL = 0x1802;
            case GL_COLOR_ATTACHMENT9 = 0x8CE9;
            case GL_COLOR_ATTACHMENT19 = 0x8CF3;
            case GL_COLOR_ATTACHMENT18 = 0x8CF2;
        }

        [AllowDuplicates]
        public enum CombinerBiasNV : uint32 {
            case GL_NONE = 0;
        }

        [AllowDuplicates]
        public enum DebugSeverity : uint32 {
            case GL_DEBUG_SEVERITY_MEDIUM = 0x9147;
            case GL_DEBUG_SEVERITY_LOW = 0x9148;
            case GL_DEBUG_SEVERITY_HIGH = 0x9146;
            case GL_DONT_CARE = 0x1100;
            case GL_DEBUG_SEVERITY_NOTIFICATION = 0x826B;
        }

        [AllowDuplicates]
        public enum VertexAttribLType : uint32 {
            case GL_DOUBLE = 0x140A;
        }

        [AllowDuplicates]
        public enum QueryParameterName : uint32 {
            case GL_QUERY_COUNTER_BITS = 0x8864;
            case GL_CURRENT_QUERY = 0x8865;
        }

        [AllowDuplicates]
        public enum BinormalPointerTypeEXT : uint32 {
            case GL_FLOAT = 0x1406;
            case GL_DOUBLE = 0x140A;
            case GL_BYTE = 0x1400;
            case GL_INT = 0x1404;
            case GL_SHORT = 0x1402;
        }

        [AllowDuplicates]
        public enum ClampColorModeARB : uint32 {
            case GL_TRUE = 1;
            case GL_FIXED_ONLY = 0x891D;
            case GL_FALSE = 0;
        }

        [AllowDuplicates]
        public enum StencilFunction : uint32 {
            case GL_EQUAL = 0x0202;
            case GL_GREATER = 0x0204;
            case GL_LEQUAL = 0x0203;
            case GL_NEVER = 0x0200;
            case GL_GEQUAL = 0x0206;
            case GL_LESS = 0x0201;
            case GL_NOTEQUAL = 0x0205;
            case GL_ALWAYS = 0x0207;
        }

        [AllowDuplicates]
        public enum ElementPointerTypeATI : uint32 {
            case GL_UNSIGNED_SHORT = 0x1403;
            case GL_UNSIGNED_BYTE = 0x1401;
            case GL_UNSIGNED_INT = 0x1405;
        }

        [AllowDuplicates]
        public enum MapBufferAccessMask : uint32 {
            case GL_MAP_COHERENT_BIT = 0x0080;
            case GL_MAP_FLUSH_EXPLICIT_BIT = 0x0010;
            case GL_MAP_UNSYNCHRONIZED_BIT = 0x0020;
            case GL_MAP_PERSISTENT_BIT = 0x0040;
            case GL_MAP_WRITE_BIT = 0x0002;
            case GL_MAP_INVALIDATE_RANGE_BIT = 0x0004;
            case GL_MAP_READ_BIT = 0x0001;
            case GL_MAP_INVALIDATE_BUFFER_BIT = 0x0008;
        }

        [AllowDuplicates]
        public enum PixelType : uint32 {
            case GL_UNSIGNED_INT_8_8_8_8 = 0x8035;
            case GL_UNSIGNED_SHORT_4_4_4_4_REV = 0x8365;
            case GL_FLOAT = 0x1406;
            case GL_BYTE = 0x1400;
            case GL_UNSIGNED_INT_8_8_8_8_REV = 0x8367;
            case GL_UNSIGNED_INT_24_8 = 0x84FA;
            case GL_UNSIGNED_SHORT_4_4_4_4 = 0x8033;
            case GL_UNSIGNED_INT_10_10_10_2 = 0x8036;
            case GL_UNSIGNED_BYTE_2_3_3_REV = 0x8362;
            case GL_UNSIGNED_INT_5_9_9_9_REV = 0x8C3E;
            case GL_UNSIGNED_INT = 0x1405;
            case GL_UNSIGNED_SHORT_1_5_5_5_REV = 0x8366;
            case GL_FLOAT_32_UNSIGNED_INT_24_8_REV = 0x8DAD;
            case GL_INT = 0x1404;
            case GL_UNSIGNED_SHORT_5_6_5 = 0x8363;
            case GL_UNSIGNED_SHORT_5_6_5_REV = 0x8364;
            case GL_UNSIGNED_SHORT = 0x1403;
            case GL_UNSIGNED_BYTE = 0x1401;
            case GL_SHORT = 0x1402;
            case GL_UNSIGNED_BYTE_3_3_2 = 0x8032;
            case GL_UNSIGNED_SHORT_5_5_5_1 = 0x8034;
        }

        [AllowDuplicates]
        public enum ColorPointerType : uint32 {
            case GL_BYTE = 0x1400;
            case GL_UNSIGNED_SHORT = 0x1403;
            case GL_UNSIGNED_BYTE = 0x1401;
            case GL_UNSIGNED_INT = 0x1405;
        }

        [AllowDuplicates]
        public enum SamplerParameterI : uint32 {
            case GL_TEXTURE_COMPARE_FUNC = 0x884D;
            case GL_TEXTURE_MIN_FILTER = 0x2801;
            case GL_TEXTURE_COMPARE_MODE = 0x884C;
            case GL_TEXTURE_WRAP_R = 0x8072;
            case GL_TEXTURE_MAG_FILTER = 0x2800;
            case GL_TEXTURE_WRAP_S = 0x2802;
            case GL_TEXTURE_WRAP_T = 0x2803;
        }

        [AllowDuplicates]
        public enum ShaderParameterName : uint32 {
            case GL_DELETE_STATUS = 0x8B80;
            case GL_SHADER_SOURCE_LENGTH = 0x8B88;
            case GL_COMPILE_STATUS = 0x8B81;
            case GL_INFO_LOG_LENGTH = 0x8B84;
            case GL_SHADER_TYPE = 0x8B4F;
        }

        [AllowDuplicates]
        public enum EnableCap : uint32 {
            case GL_VERTEX_PROGRAM_POINT_SIZE = 0x8642;
            case GL_DEPTH_TEST = 0x0B71;
            case GL_CLIP_DISTANCE1 = 0x3001;
            case GL_CLIP_DISTANCE0 = 0x3000;
            case GL_SAMPLE_ALPHA_TO_ONE = 0x809F;
            case GL_TEXTURE_CUBE_MAP_SEAMLESS = 0x884F;
            case GL_CLIP_DISTANCE3 = 0x3003;
            case GL_CLIP_DISTANCE2 = 0x3002;
            case GL_CLIP_DISTANCE5 = 0x3005;
            case GL_POLYGON_OFFSET_FILL = 0x8037;
            case GL_CLIP_DISTANCE4 = 0x3004;
            case GL_SCISSOR_TEST = 0x0C11;
            case GL_CLIP_DISTANCE7 = 0x3007;
            case GL_SAMPLE_MASK = 0x8E51;
            case GL_CULL_FACE = 0x0B44;
            case GL_CLIP_DISTANCE6 = 0x3006;
            case GL_TEXTURE_2D = 0x0DE1;
            case GL_POST_COLOR_MATRIX_COLOR_TABLE = 0x80D2;
            case GL_LINE_SMOOTH = 0x0B20;
            case GL_PROGRAM_POINT_SIZE = 0x8642;
            case GL_COLOR_TABLE = 0x80D0;
            case GL_FRAMEBUFFER_SRGB = 0x8DB9;
            case GL_POLYGON_OFFSET_LINE = 0x2A02;
            case GL_MULTISAMPLE = 0x809D;
            case GL_PRIMITIVE_RESTART_FIXED_INDEX = 0x8D69;
            case GL_SAMPLE_SHADING = 0x8C36;
            case GL_RASTERIZER_DISCARD = 0x8C89;
            case GL_COLOR_LOGIC_OP = 0x0BF2;
            case GL_SAMPLE_COVERAGE = 0x80A0;
            case GL_PRIMITIVE_RESTART = 0x8F9D;
            case GL_POLYGON_SMOOTH = 0x0B41;
            case GL_STENCIL_TEST = 0x0B90;
            case GL_TEXTURE_1D = 0x0DE0;
            case GL_SAMPLE_ALPHA_TO_COVERAGE = 0x809E;
            case GL_DEBUG_OUTPUT_SYNCHRONOUS = 0x8242;
            case GL_DEBUG_OUTPUT = 0x92E0;
            case GL_DEPTH_CLAMP = 0x864F;
            case GL_BLEND = 0x0BE2;
            case GL_DITHER = 0x0BD0;
            case GL_POLYGON_OFFSET_POINT = 0x2A01;
            case GL_POST_CONVOLUTION_COLOR_TABLE = 0x80D1;
        }

        [AllowDuplicates]
        public enum VertexAttribType : uint32 {
            case GL_INT_2_10_10_10_REV = 0x8D9F;
            case GL_FLOAT = 0x1406;
            case GL_DOUBLE = 0x140A;
            case GL_BYTE = 0x1400;
            case GL_HALF_FLOAT = 0x140B;
            case GL_UNSIGNED_INT = 0x1405;
            case GL_UNSIGNED_INT_2_10_10_10_REV = 0x8368;
            case GL_INT = 0x1404;
            case GL_UNSIGNED_INT_10F_11F_11F_REV = 0x8C3B;
            case GL_UNSIGNED_SHORT = 0x1403;
            case GL_FIXED = 0x140C;
            case GL_UNSIGNED_BYTE = 0x1401;
            case GL_SHORT = 0x1402;
        }

        [AllowDuplicates]
        public enum SyncObjectMask : uint32 {
            case GL_SYNC_FLUSH_COMMANDS_BIT = 0x00000001;
        }

        [AllowDuplicates]
        public enum CopyBufferSubDataTarget : uint32 {
            case GL_UNIFORM_BUFFER = 0x8A11;
            case GL_COPY_WRITE_BUFFER = 0x8F37;
            case GL_QUERY_BUFFER = 0x9192;
            case GL_DISPATCH_INDIRECT_BUFFER = 0x90EE;
            case GL_TRANSFORM_FEEDBACK_BUFFER = 0x8C8E;
            case GL_DRAW_INDIRECT_BUFFER = 0x8F3F;
            case GL_PIXEL_UNPACK_BUFFER = 0x88EC;
            case GL_ELEMENT_ARRAY_BUFFER = 0x8893;
            case GL_PIXEL_PACK_BUFFER = 0x88EB;
            case GL_TEXTURE_BUFFER = 0x8C2A;
            case GL_COPY_READ_BUFFER = 0x8F36;
            case GL_ATOMIC_COUNTER_BUFFER = 0x92C0;
            case GL_ARRAY_BUFFER = 0x8892;
            case GL_SHADER_STORAGE_BUFFER = 0x90D2;
        }

        [AllowDuplicates]
        public enum RenderbufferTarget : uint32 {
            case GL_RENDERBUFFER = 0x8D41;
        }

        [AllowDuplicates]
        public enum RenderbufferParameterName : uint32 {
            case GL_RENDERBUFFER_SAMPLES = 0x8CAB;
            case GL_RENDERBUFFER_INTERNAL_FORMAT = 0x8D44;
            case GL_RENDERBUFFER_DEPTH_SIZE = 0x8D54;
            case GL_RENDERBUFFER_ALPHA_SIZE = 0x8D53;
            case GL_RENDERBUFFER_STENCIL_SIZE = 0x8D55;
            case GL_RENDERBUFFER_BLUE_SIZE = 0x8D52;
            case GL_RENDERBUFFER_HEIGHT = 0x8D43;
            case GL_RENDERBUFFER_RED_SIZE = 0x8D50;
            case GL_RENDERBUFFER_WIDTH = 0x8D42;
            case GL_RENDERBUFFER_GREEN_SIZE = 0x8D51;
        }

        [AllowDuplicates]
        public enum VertexAttribPointerPropertyARB : uint32 {
            case GL_VERTEX_ATTRIB_ARRAY_POINTER = 0x8645;
        }

        [AllowDuplicates]
        public enum FogPointerTypeEXT : uint32 {
            case GL_FLOAT = 0x1406;
            case GL_DOUBLE = 0x140A;
        }

        [AllowDuplicates]
        public enum SamplerParameterF : uint32 {
            case GL_TEXTURE_MIN_LOD = 0x813A;
            case GL_TEXTURE_LOD_BIAS = 0x8501;
            case GL_TEXTURE_BORDER_COLOR = 0x1004;
            case GL_TEXTURE_MAX_LOD = 0x813B;
        }

        [AllowDuplicates]
        public enum MaterialFace : uint32 {
            case GL_FRONT = 0x0404;
            case GL_BACK = 0x0405;
            case GL_FRONT_AND_BACK = 0x0408;
        }

        [AllowDuplicates]
        public enum VertexWeightPointerTypeEXT : uint32 {
            case GL_FLOAT = 0x1406;
        }

        [AllowDuplicates]
        public enum BufferAccessARB : uint32 {
            case GL_WRITE_ONLY = 0x88B9;
            case GL_READ_WRITE = 0x88BA;
            case GL_READ_ONLY = 0x88B8;
        }

        [AllowDuplicates]
        public enum StencilOp : uint32 {
            case GL_DECR_WRAP = 0x8508;
            case GL_KEEP = 0x1E00;
            case GL_INCR_WRAP = 0x8507;
            case GL_INVERT = 0x150A;
            case GL_INCR = 0x1E02;
            case GL_ZERO = 0;
            case GL_REPLACE = 0x1E01;
            case GL_DECR = 0x1E03;
        }

        [AllowDuplicates]
        public enum ErrorCode : uint32 {
            case GL_NO_ERROR = 0;
            case GL_INVALID_OPERATION = 0x0502;
            case GL_INVALID_FRAMEBUFFER_OPERATION = 0x0506;
            case GL_INVALID_ENUM = 0x0500;
            case GL_OUT_OF_MEMORY = 0x0505;
            case GL_INVALID_VALUE = 0x0501;
            case GL_CONTEXT_LOST = 0x0507;
        }

        [AllowDuplicates]
        public enum CombinerScaleNV : uint32 {
            case GL_NONE = 0;
        }

        [AllowDuplicates]
        public enum SeparableTargetEXT : uint32 {
            case GL_SEPARABLE_2D = 0x8012;
        }

        public static function void(uint32 pipeline, uint32 program) glActiveShaderProgram;
        public static function void(TextureUnit texture) glActiveTexture;
        public static function void(uint32 program, uint32 shader) glAttachShader;
        public static function void(uint32 id, ConditionalRenderMode mode) glBeginConditionalRender;
        public static function void(QueryTarget target, uint32 id) glBeginQuery;
        public static function void(QueryTarget target, uint32 index, uint32 id) glBeginQueryIndexed;
        public static function void(PrimitiveType primitiveMode) glBeginTransformFeedback;
        public static function void(uint32 program, uint32 index, char8* name) glBindAttribLocation;
        public static function void(BufferTargetARB target, uint32 buffer) glBindBuffer;
        public static function void(BufferTargetARB target, uint32 index, uint32 buffer) glBindBufferBase;
        public static function void(BufferTargetARB target, uint32 index, uint32 buffer, int32 offset, int32 size) glBindBufferRange;
        public static function void(BufferTargetARB target, uint32 first, int32 count, uint32* buffers) glBindBuffersBase;
        public static function void(BufferTargetARB target, uint32 first, int32 count, uint32* buffers, int32* offsets, int32* sizes) glBindBuffersRange;
        public static function void(uint32 program, uint32 color, char8* name) glBindFragDataLocation;
        public static function void(uint32 program, uint32 colorNumber, uint32 index, char8* name) glBindFragDataLocationIndexed;
        public static function void(FramebufferTarget target, uint32 framebuffer) glBindFramebuffer;
        public static function void(uint32 unit, uint32 texture, int32 level, Boolean layered, int32 layer, BufferAccessARB access, InternalFormat format) glBindImageTexture;
        public static function void(uint32 first, int32 count, uint32* textures) glBindImageTextures;
        public static function void(uint32 pipeline) glBindProgramPipeline;
        public static function void(RenderbufferTarget target, uint32 renderbuffer) glBindRenderbuffer;
        public static function void(uint32 unit, uint32 sampler) glBindSampler;
        public static function void(uint32 first, int32 count, uint32* samplers) glBindSamplers;
        public static function void(TextureTarget target, uint32 texture) glBindTexture;
        public static function void(uint32 unit, uint32 texture) glBindTextureUnit;
        public static function void(uint32 first, int32 count, uint32* textures) glBindTextures;
        public static function void(BindTransformFeedbackTarget target, uint32 id) glBindTransformFeedback;
        public static function void(uint32 array) glBindVertexArray;
        public static function void(uint32 bindingindex, uint32 buffer, int32 offset, int32 stride) glBindVertexBuffer;
        public static function void(uint32 first, int32 count, uint32* buffers, int32* offsets, int32* strides) glBindVertexBuffers;
        public static function void(float red, float green, float blue, float alpha) glBlendColor;
        public static function void(BlendEquationModeEXT mode) glBlendEquation;
        public static function void(BlendEquationModeEXT modeRGB, BlendEquationModeEXT modeAlpha) glBlendEquationSeparate;
        public static function void(uint32 buf, BlendEquationModeEXT modeRGB, BlendEquationModeEXT modeAlpha) glBlendEquationSeparatei;
        public static function void(uint32 buf, BlendEquationModeEXT mode) glBlendEquationi;
        public static function void(BlendingFactor sfactor, BlendingFactor dfactor) glBlendFunc;
        public static function void(BlendingFactor sfactorRGB, BlendingFactor dfactorRGB, BlendingFactor sfactorAlpha, BlendingFactor dfactorAlpha) glBlendFuncSeparate;
        public static function void(uint32 buf, BlendingFactor srcRGB, BlendingFactor dstRGB, BlendingFactor srcAlpha, BlendingFactor dstAlpha) glBlendFuncSeparatei;
        public static function void(uint32 buf, BlendingFactor src, BlendingFactor dst) glBlendFunci;
        public static function void(int32 srcX0, int32 srcY0, int32 srcX1, int32 srcY1, int32 dstX0, int32 dstY0, int32 dstX1, int32 dstY1, ClearBufferMask mask, BlitFramebufferFilter filter) glBlitFramebuffer;
        public static function void(uint32 readFramebuffer, uint32 drawFramebuffer, int32 srcX0, int32 srcY0, int32 srcX1, int32 srcY1, int32 dstX0, int32 dstY0, int32 dstX1, int32 dstY1, ClearBufferMask mask, BlitFramebufferFilter filter) glBlitNamedFramebuffer;
        public static function void(BufferTargetARB target, int32 size, void* data, BufferUsageARB usage) glBufferData;
        public static function void(BufferStorageTarget target, int32 size, void* data, BufferStorageMask flags) glBufferStorage;
        public static function void(BufferTargetARB target, int32 offset, int32 size, void* data) glBufferSubData;
        public static function FramebufferStatus(FramebufferTarget target) glCheckFramebufferStatus;
        public static function FramebufferStatus(uint32 framebuffer, FramebufferTarget target) glCheckNamedFramebufferStatus;
        public static function void(ClampColorTargetARB target, ClampColorModeARB clamp) glClampColor;
        public static function void(ClearBufferMask mask) glClear;
        public static function void(BufferStorageTarget target, SizedInternalFormat internalformat, PixelFormat format, PixelType type, void* data) glClearBufferData;
        public static function void(BufferTargetARB target, SizedInternalFormat internalformat, int32 offset, int32 size, PixelFormat format, PixelType type, void* data) glClearBufferSubData;
        public static function void(Buffer buffer, int32 drawbuffer, float depth, int32 stencil) glClearBufferfi;
        public static function void(Buffer buffer, int32 drawbuffer, float* value) glClearBufferfv;
        public static function void(Buffer buffer, int32 drawbuffer, int32* value) glClearBufferiv;
        public static function void(Buffer buffer, int32 drawbuffer, uint32* value) glClearBufferuiv;
        public static function void(float red, float green, float blue, float alpha) glClearColor;
        public static function void(double depth) glClearDepth;
        public static function void(float d) glClearDepthf;
        public static function void(uint32 buffer, SizedInternalFormat internalformat, PixelFormat format, PixelType type, void* data) glClearNamedBufferData;
        public static function void(uint32 buffer, SizedInternalFormat internalformat, int32 offset, int32 size, PixelFormat format, PixelType type, void* data) glClearNamedBufferSubData;
        public static function void(uint32 framebuffer, Buffer buffer, int32 drawbuffer, float depth, int32 stencil) glClearNamedFramebufferfi;
        public static function void(uint32 framebuffer, Buffer buffer, int32 drawbuffer, float* value) glClearNamedFramebufferfv;
        public static function void(uint32 framebuffer, Buffer buffer, int32 drawbuffer, int32* value) glClearNamedFramebufferiv;
        public static function void(uint32 framebuffer, Buffer buffer, int32 drawbuffer, uint32* value) glClearNamedFramebufferuiv;
        public static function void(int32 s) glClearStencil;
        public static function void(uint32 texture, int32 level, PixelFormat format, PixelType type, void* data) glClearTexImage;
        public static function void(uint32 texture, int32 level, int32 xoffset, int32 yoffset, int32 zoffset, int32 width, int32 height, int32 depth, PixelFormat format, PixelType type, void* data) glClearTexSubImage;
        public static function SyncStatus(void* sync, SyncObjectMask flags, uint64 timeout) glClientWaitSync;
        public static function void(ClipControlOrigin origin, ClipControlDepth depth) glClipControl;
        public static function void(Boolean red, Boolean green, Boolean blue, Boolean alpha) glColorMask;
        public static function void(uint32 index, Boolean r, Boolean g, Boolean b, Boolean a) glColorMaski;
        public static function void(ColorPointerType type, uint32 color) glColorP3ui;
        public static function void(ColorPointerType type, uint32* color) glColorP3uiv;
        public static function void(ColorPointerType type, uint32 color) glColorP4ui;
        public static function void(ColorPointerType type, uint32* color) glColorP4uiv;
        public static function void(uint32 shader) glCompileShader;
        public static function void(TextureTarget target, int32 level, InternalFormat internalformat, int32 width, int32 border, int32 imageSize, void* data) glCompressedTexImage1D;
        public static function void(TextureTarget target, int32 level, InternalFormat internalformat, int32 width, int32 height, int32 border, int32 imageSize, void* data) glCompressedTexImage2D;
        public static function void(TextureTarget target, int32 level, InternalFormat internalformat, int32 width, int32 height, int32 depth, int32 border, int32 imageSize, void* data) glCompressedTexImage3D;
        public static function void(TextureTarget target, int32 level, int32 xoffset, int32 width, PixelFormat format, int32 imageSize, void* data) glCompressedTexSubImage1D;
        public static function void(TextureTarget target, int32 level, int32 xoffset, int32 yoffset, int32 width, int32 height, PixelFormat format, int32 imageSize, void* data) glCompressedTexSubImage2D;
        public static function void(TextureTarget target, int32 level, int32 xoffset, int32 yoffset, int32 zoffset, int32 width, int32 height, int32 depth, PixelFormat format, int32 imageSize, void* data) glCompressedTexSubImage3D;
        public static function void(uint32 texture, int32 level, int32 xoffset, int32 width, PixelFormat format, int32 imageSize, void* data) glCompressedTextureSubImage1D;
        public static function void(uint32 texture, int32 level, int32 xoffset, int32 yoffset, int32 width, int32 height, PixelFormat format, int32 imageSize, void* data) glCompressedTextureSubImage2D;
        public static function void(uint32 texture, int32 level, int32 xoffset, int32 yoffset, int32 zoffset, int32 width, int32 height, int32 depth, PixelFormat format, int32 imageSize, void* data) glCompressedTextureSubImage3D;
        public static function void(CopyBufferSubDataTarget readTarget, CopyBufferSubDataTarget writeTarget, int32 readOffset, int32 writeOffset, int32 size) glCopyBufferSubData;
        public static function void(uint32 srcName, CopyImageSubDataTarget srcTarget, int32 srcLevel, int32 srcX, int32 srcY, int32 srcZ, uint32 dstName, CopyImageSubDataTarget dstTarget, int32 dstLevel, int32 dstX, int32 dstY, int32 dstZ, int32 srcWidth, int32 srcHeight, int32 srcDepth) glCopyImageSubData;
        public static function void(uint32 readBuffer, uint32 writeBuffer, int32 readOffset, int32 writeOffset, int32 size) glCopyNamedBufferSubData;
        public static function void(TextureTarget target, int32 level, InternalFormat internalformat, int32 x, int32 y, int32 width, int32 border) glCopyTexImage1D;
        public static function void(TextureTarget target, int32 level, InternalFormat internalformat, int32 x, int32 y, int32 width, int32 height, int32 border) glCopyTexImage2D;
        public static function void(TextureTarget target, int32 level, int32 xoffset, int32 x, int32 y, int32 width) glCopyTexSubImage1D;
        public static function void(TextureTarget target, int32 level, int32 xoffset, int32 yoffset, int32 x, int32 y, int32 width, int32 height) glCopyTexSubImage2D;
        public static function void(TextureTarget target, int32 level, int32 xoffset, int32 yoffset, int32 zoffset, int32 x, int32 y, int32 width, int32 height) glCopyTexSubImage3D;
        public static function void(uint32 texture, int32 level, int32 xoffset, int32 x, int32 y, int32 width) glCopyTextureSubImage1D;
        public static function void(uint32 texture, int32 level, int32 xoffset, int32 yoffset, int32 x, int32 y, int32 width, int32 height) glCopyTextureSubImage2D;
        public static function void(uint32 texture, int32 level, int32 xoffset, int32 yoffset, int32 zoffset, int32 x, int32 y, int32 width, int32 height) glCopyTextureSubImage3D;
        public static function void(int32 n, uint32* buffers) glCreateBuffers;
        public static function void(int32 n, uint32* framebuffers) glCreateFramebuffers;
        public static function uint32() glCreateProgram;
        public static function void(int32 n, uint32* pipelines) glCreateProgramPipelines;
        public static function void(QueryTarget target, int32 n, uint32* ids) glCreateQueries;
        public static function void(int32 n, uint32* renderbuffers) glCreateRenderbuffers;
        public static function void(int32 n, uint32* samplers) glCreateSamplers;
        public static function uint32(ShaderType type) glCreateShader;
        public static function uint32(ShaderType type, int32 count, char8** strings) glCreateShaderProgramv;
        public static function void(TextureTarget target, int32 n, uint32* textures) glCreateTextures;
        public static function void(int32 n, uint32* ids) glCreateTransformFeedbacks;
        public static function void(int32 n, uint32* arrays) glCreateVertexArrays;
        public static function void(CullFaceMode mode) glCullFace;
        public static function void(function void(DebugSource source, DebugType type, uint32 id, DebugSeverity severity, int32 length, char8* message, void* userParam) callback, void* userParam) glDebugMessageCallback;
        public static function void(DebugSource source, DebugType type, DebugSeverity severity, int32 count, uint32* ids, Boolean enabled) glDebugMessageControl;
        public static function void(DebugSource source, DebugType type, uint32 id, DebugSeverity severity, int32 length, char8* buf) glDebugMessageInsert;
        public static function void(int32 n, uint32* buffers) glDeleteBuffers;
        public static function void(int32 n, uint32* framebuffers) glDeleteFramebuffers;
        public static function void(uint32 program) glDeleteProgram;
        public static function void(int32 n, uint32* pipelines) glDeleteProgramPipelines;
        public static function void(int32 n, uint32* ids) glDeleteQueries;
        public static function void(int32 n, uint32* renderbuffers) glDeleteRenderbuffers;
        public static function void(int32 count, uint32* samplers) glDeleteSamplers;
        public static function void(uint32 shader) glDeleteShader;
        public static function void(void* sync) glDeleteSync;
        public static function void(int32 n, uint32* textures) glDeleteTextures;
        public static function void(int32 n, uint32* ids) glDeleteTransformFeedbacks;
        public static function void(int32 n, uint32* arrays) glDeleteVertexArrays;
        public static function void(DepthFunction func) glDepthFunc;
        public static function void(Boolean flag) glDepthMask;
        public static function void(double n, double f) glDepthRange;
        public static function void(uint32 first, int32 count, double* v) glDepthRangeArrayv;
        public static function void(uint32 index, double n, double f) glDepthRangeIndexed;
        public static function void(float n, float f) glDepthRangef;
        public static function void(uint32 program, uint32 shader) glDetachShader;
        public static function void(EnableCap cap) glDisable;
        public static function void(uint32 vaobj, uint32 index) glDisableVertexArrayAttrib;
        public static function void(uint32 index) glDisableVertexAttribArray;
        public static function void(EnableCap target, uint32 index) glDisablei;
        public static function void(uint32 num_groups_x, uint32 num_groups_y, uint32 num_groups_z) glDispatchCompute;
        public static function void(int32 indirect) glDispatchComputeIndirect;
        public static function void(PrimitiveType mode, int32 first, int32 count) glDrawArrays;
        public static function void(PrimitiveType mode, void* indirect) glDrawArraysIndirect;
        public static function void(PrimitiveType mode, int32 first, int32 count, int32 instancecount) glDrawArraysInstanced;
        public static function void(PrimitiveType mode, int32 first, int32 count, int32 instancecount, uint32 baseinstance) glDrawArraysInstancedBaseInstance;
        public static function void(DrawBufferMode buf) glDrawBuffer;
        public static function void(int32 n, DrawBufferMode* bufs) glDrawBuffers;
        public static function void(PrimitiveType mode, int32 count, DrawElementsType type, void* indices) glDrawElements;
        public static function void(PrimitiveType mode, int32 count, DrawElementsType type, void* indices, int32 basevertex) glDrawElementsBaseVertex;
        public static function void(PrimitiveType mode, DrawElementsType type, void* indirect) glDrawElementsIndirect;
        public static function void(PrimitiveType mode, int32 count, DrawElementsType type, void* indices, int32 instancecount) glDrawElementsInstanced;
        public static function void(PrimitiveType mode, int32 count, PrimitiveType type, void* indices, int32 instancecount, uint32 baseinstance) glDrawElementsInstancedBaseInstance;
        public static function void(PrimitiveType mode, int32 count, DrawElementsType type, void* indices, int32 instancecount, int32 basevertex) glDrawElementsInstancedBaseVertex;
        public static function void(PrimitiveType mode, int32 count, DrawElementsType type, void* indices, int32 instancecount, int32 basevertex, uint32 baseinstance) glDrawElementsInstancedBaseVertexBaseInstance;
        public static function void(PrimitiveType mode, uint32 start, uint32 end, int32 count, DrawElementsType type, void* indices) glDrawRangeElements;
        public static function void(PrimitiveType mode, uint32 start, uint32 end, int32 count, DrawElementsType type, void* indices, int32 basevertex) glDrawRangeElementsBaseVertex;
        public static function void(PrimitiveType mode, uint32 id) glDrawTransformFeedback;
        public static function void(PrimitiveType mode, uint32 id, int32 instancecount) glDrawTransformFeedbackInstanced;
        public static function void(PrimitiveType mode, uint32 id, uint32 stream) glDrawTransformFeedbackStream;
        public static function void(PrimitiveType mode, uint32 id, uint32 stream, int32 instancecount) glDrawTransformFeedbackStreamInstanced;
        public static function void(EnableCap cap) glEnable;
        public static function void(uint32 vaobj, uint32 index) glEnableVertexArrayAttrib;
        public static function void(uint32 index) glEnableVertexAttribArray;
        public static function void(EnableCap target, uint32 index) glEnablei;
        public static function void() glEndConditionalRender;
        public static function void(QueryTarget target) glEndQuery;
        public static function void(QueryTarget target, uint32 index) glEndQueryIndexed;
        public static function void() glEndTransformFeedback;
        public static function void*(SyncCondition condition, SyncBehaviorFlags flags) glFenceSync;
        public static function void() glFinish;
        public static function void() glFlush;
        public static function void(BufferTargetARB target, int32 offset, int32 length) glFlushMappedBufferRange;
        public static function void(uint32 buffer, int32 offset, int32 length) glFlushMappedNamedBufferRange;
        public static function void(FramebufferTarget target, FramebufferParameterName pname, int32 param) glFramebufferParameteri;
        public static function void(FramebufferTarget target, FramebufferAttachment attachment, RenderbufferTarget renderbuffertarget, uint32 renderbuffer) glFramebufferRenderbuffer;
        public static function void(FramebufferTarget target, FramebufferAttachment attachment, uint32 texture, int32 level) glFramebufferTexture;
        public static function void(FramebufferTarget target, FramebufferAttachment attachment, TextureTarget textarget, uint32 texture, int32 level) glFramebufferTexture1D;
        public static function void(FramebufferTarget target, FramebufferAttachment attachment, TextureTarget textarget, uint32 texture, int32 level) glFramebufferTexture2D;
        public static function void(FramebufferTarget target, FramebufferAttachment attachment, TextureTarget textarget, uint32 texture, int32 level, int32 zoffset) glFramebufferTexture3D;
        public static function void(FramebufferTarget target, FramebufferAttachment attachment, uint32 texture, int32 level, int32 layer) glFramebufferTextureLayer;
        public static function void(FrontFaceDirection mode) glFrontFace;
        public static function void(int32 n, uint32* buffers) glGenBuffers;
        public static function void(int32 n, uint32* framebuffers) glGenFramebuffers;
        public static function void(int32 n, uint32* pipelines) glGenProgramPipelines;
        public static function void(int32 n, uint32* ids) glGenQueries;
        public static function void(int32 n, uint32* renderbuffers) glGenRenderbuffers;
        public static function void(int32 count, uint32* samplers) glGenSamplers;
        public static function void(int32 n, uint32* textures) glGenTextures;
        public static function void(int32 n, uint32* ids) glGenTransformFeedbacks;
        public static function void(int32 n, uint32* arrays) glGenVertexArrays;
        public static function void(TextureTarget target) glGenerateMipmap;
        public static function void(uint32 texture) glGenerateTextureMipmap;
        public static function void(uint32 program, uint32 bufferIndex, AtomicCounterBufferPName pname, int32* parameters) glGetActiveAtomicCounterBufferiv;
        public static function void(uint32 program, uint32 index, int32 bufSize, int32* length, int32* size, AttributeType* type, char8* name) glGetActiveAttrib;
        public static function void(uint32 program, ShaderType shadertype, uint32 index, int32 bufSize, int32* length, char8* name) glGetActiveSubroutineName;
        public static function void(uint32 program, ShaderType shadertype, uint32 index, int32 bufSize, int32* length, char8* name) glGetActiveSubroutineUniformName;
        public static function void(uint32 program, ShaderType shadertype, uint32 index, SubroutineParameterName pname, int32* values) glGetActiveSubroutineUniformiv;
        public static function void(uint32 program, uint32 index, int32 bufSize, int32* length, int32* size, UniformType* type, char8* name) glGetActiveUniform;
        public static function void(uint32 program, uint32 uniformBlockIndex, int32 bufSize, int32* length, char8* uniformBlockName) glGetActiveUniformBlockName;
        public static function void(uint32 program, uint32 uniformBlockIndex, UniformBlockPName pname, int32* parameters) glGetActiveUniformBlockiv;
        public static function void(uint32 program, uint32 uniformIndex, int32 bufSize, int32* length, char8* uniformName) glGetActiveUniformName;
        public static function void(uint32 program, int32 uniformCount, uint32* uniformIndices, UniformPName pname, int32* parameters) glGetActiveUniformsiv;
        public static function void(uint32 program, int32 maxCount, int32* count, uint32* shaders) glGetAttachedShaders;
        public static function int32(uint32 program, char8* name) glGetAttribLocation;
        public static function void(BufferTargetARB target, uint32 index, Boolean* data) glGetBooleani_v;
        public static function void(GetPName pname, Boolean* data) glGetBooleanv;
        public static function void(BufferTargetARB target, BufferPNameARB pname, int64* parameters) glGetBufferParameteri64v;
        public static function void(BufferTargetARB target, BufferPNameARB pname, int32* parameters) glGetBufferParameteriv;
        public static function void(BufferTargetARB target, BufferPointerNameARB pname, void** parameters) glGetBufferPointerv;
        public static function void(BufferTargetARB target, int32 offset, int32 size, void* data) glGetBufferSubData;
        public static function void(TextureTarget target, int32 level, void* img) glGetCompressedTexImage;
        public static function void(uint32 texture, int32 level, int32 bufSize, void* pixels) glGetCompressedTextureImage;
        public static function void(uint32 texture, int32 level, int32 xoffset, int32 yoffset, int32 zoffset, int32 width, int32 height, int32 depth, int32 bufSize, void* pixels) glGetCompressedTextureSubImage;
        public static function uint32(uint32 count, int32 bufSize, DebugSource* sources, DebugType* types, uint32* ids, DebugSeverity* severities, int32* lengths, char8* messageLog) glGetDebugMessageLog;
        public static function void(GetPName target, uint32 index, double* data) glGetDoublei_v;
        public static function void(GetPName pname, double* data) glGetDoublev;
        public static function ErrorCode() glGetError;
        public static function void(GetPName target, uint32 index, float* data) glGetFloati_v;
        public static function void(GetPName pname, float* data) glGetFloatv;
        public static function int32(uint32 program, char8* name) glGetFragDataIndex;
        public static function int32(uint32 program, char8* name) glGetFragDataLocation;
        public static function void(FramebufferTarget target, FramebufferAttachment attachment, FramebufferAttachmentParameterName pname, int32* parameters) glGetFramebufferAttachmentParameteriv;
        public static function void(FramebufferTarget target, FramebufferAttachmentParameterName pname, int32* parameters) glGetFramebufferParameteriv;
        public static function GraphicsResetStatus() glGetGraphicsResetStatus;
        public static function void(GetPName target, uint32 index, int64* data) glGetInteger64i_v;
        public static function void(GetPName pname, int64* data) glGetInteger64v;
        public static function void(GetPName target, uint32 index, int32* data) glGetIntegeri_v;
        public static function void(GetPName pname, int32* data) glGetIntegerv;
        public static function void(TextureTarget target, InternalFormat internalformat, InternalFormatPName pname, int32 count, int64* parameters) glGetInternalformati64v;
        public static function void(TextureTarget target, InternalFormat internalformat, InternalFormatPName pname, int32 count, int32* parameters) glGetInternalformativ;
        public static function void(GetMultisamplePNameNV pname, uint32 index, float* val) glGetMultisamplefv;
        public static function void(uint32 buffer, BufferPNameARB pname, int64* parameters) glGetNamedBufferParameteri64v;
        public static function void(uint32 buffer, BufferPNameARB pname, int32* parameters) glGetNamedBufferParameteriv;
        public static function void(uint32 buffer, BufferPointerNameARB pname, void** parameters) glGetNamedBufferPointerv;
        public static function void(uint32 buffer, int32 offset, int32 size, void* data) glGetNamedBufferSubData;
        public static function void(uint32 framebuffer, FramebufferAttachment attachment, FramebufferAttachmentParameterName pname, int32* parameters) glGetNamedFramebufferAttachmentParameteriv;
        public static function void(uint32 framebuffer, GetFramebufferParameter pname, int32* param) glGetNamedFramebufferParameteriv;
        public static function void(uint32 renderbuffer, RenderbufferParameterName pname, int32* parameters) glGetNamedRenderbufferParameteriv;
        public static function void(ObjectIdentifier identifier, uint32 name, int32 bufSize, int32* length, char8* label) glGetObjectLabel;
        public static function void(void* ptr, int32 bufSize, int32* length, char8* label) glGetObjectPtrLabel;
        public static function void(GetPointervPName pname, void** parameters) glGetPointerv;
        public static function void(uint32 program, int32 bufSize, int32* length, uint32* binaryFormat, void* binary) glGetProgramBinary;
        public static function void(uint32 program, int32 bufSize, int32* length, char8* infoLog) glGetProgramInfoLog;
        public static function void(uint32 program, ProgramInterface programInterface, ProgramInterfacePName pname, int32* parameters) glGetProgramInterfaceiv;
        public static function void(uint32 pipeline, int32 bufSize, int32* length, char8* infoLog) glGetProgramPipelineInfoLog;
        public static function void(uint32 pipeline, PipelineParameterName pname, int32* parameters) glGetProgramPipelineiv;
        public static function uint32(uint32 program, ProgramInterface programInterface, char8* name) glGetProgramResourceIndex;
        public static function int32(uint32 program, ProgramInterface programInterface, char8* name) glGetProgramResourceLocation;
        public static function int32(uint32 program, ProgramInterface programInterface, char8* name) glGetProgramResourceLocationIndex;
        public static function void(uint32 program, ProgramInterface programInterface, uint32 index, int32 bufSize, int32* length, char8* name) glGetProgramResourceName;
        public static function void(uint32 program, ProgramInterface programInterface, uint32 index, int32 propCount, ProgramResourceProperty* props, int32 count, int32* length, int32* parameters) glGetProgramResourceiv;
        public static function void(uint32 program, ShaderType shadertype, ProgramStagePName pname, int32* values) glGetProgramStageiv;
        public static function void(uint32 program, ProgramPropertyARB pname, int32* parameters) glGetProgramiv;
        public static function void(uint32 id, uint32 buffer, QueryObjectParameterName pname, int32 offset) glGetQueryBufferObjecti64v;
        public static function void(uint32 id, uint32 buffer, QueryObjectParameterName pname, int32 offset) glGetQueryBufferObjectiv;
        public static function void(uint32 id, uint32 buffer, QueryObjectParameterName pname, int32 offset) glGetQueryBufferObjectui64v;
        public static function void(uint32 id, uint32 buffer, QueryObjectParameterName pname, int32 offset) glGetQueryBufferObjectuiv;
        public static function void(QueryTarget target, uint32 index, QueryParameterName pname, int32* parameters) glGetQueryIndexediv;
        public static function void(uint32 id, QueryObjectParameterName pname, int64* parameters) glGetQueryObjecti64v;
        public static function void(uint32 id, QueryObjectParameterName pname, int32* parameters) glGetQueryObjectiv;
        public static function void(uint32 id, QueryObjectParameterName pname, uint64* parameters) glGetQueryObjectui64v;
        public static function void(uint32 id, QueryObjectParameterName pname, uint32* parameters) glGetQueryObjectuiv;
        public static function void(QueryTarget target, QueryParameterName pname, int32* parameters) glGetQueryiv;
        public static function void(RenderbufferTarget target, RenderbufferParameterName pname, int32* parameters) glGetRenderbufferParameteriv;
        public static function void(uint32 sampler, SamplerParameterI pname, int32* parameters) glGetSamplerParameterIiv;
        public static function void(uint32 sampler, SamplerParameterI pname, uint32* parameters) glGetSamplerParameterIuiv;
        public static function void(uint32 sampler, SamplerParameterF pname, float* parameters) glGetSamplerParameterfv;
        public static function void(uint32 sampler, SamplerParameterI pname, int32* parameters) glGetSamplerParameteriv;
        public static function void(uint32 shader, int32 bufSize, int32* length, char8* infoLog) glGetShaderInfoLog;
        public static function void(ShaderType shadertype, PrecisionType precisiontype, int32* range, int32* precision) glGetShaderPrecisionFormat;
        public static function void(uint32 shader, int32 bufSize, int32* length, char8* source) glGetShaderSource;
        public static function void(uint32 shader, ShaderParameterName pname, int32* parameters) glGetShaderiv;
        public static function char8*(StringName name) glGetString;
        public static function char8*(StringName name, uint32 index) glGetStringi;
        public static function uint32(uint32 program, ShaderType shadertype, char8* name) glGetSubroutineIndex;
        public static function int32(uint32 program, ShaderType shadertype, char8* name) glGetSubroutineUniformLocation;
        public static function void(void* sync, SyncParameterName pname, int32 count, int32* length, int32* values) glGetSynciv;
        public static function void(TextureTarget target, int32 level, PixelFormat format, PixelType type, void* pixels) glGetTexImage;
        public static function void(TextureTarget target, int32 level, GetTextureParameter pname, float* parameters) glGetTexLevelParameterfv;
        public static function void(TextureTarget target, int32 level, GetTextureParameter pname, int32* parameters) glGetTexLevelParameteriv;
        public static function void(TextureTarget target, GetTextureParameter pname, int32* parameters) glGetTexParameterIiv;
        public static function void(TextureTarget target, GetTextureParameter pname, uint32* parameters) glGetTexParameterIuiv;
        public static function void(TextureTarget target, GetTextureParameter pname, float* parameters) glGetTexParameterfv;
        public static function void(TextureTarget target, GetTextureParameter pname, int32* parameters) glGetTexParameteriv;
        public static function void(uint32 texture, int32 level, PixelFormat format, PixelType type, int32 bufSize, void* pixels) glGetTextureImage;
        public static function void(uint32 texture, int32 level, GetTextureParameter pname, float* parameters) glGetTextureLevelParameterfv;
        public static function void(uint32 texture, int32 level, GetTextureParameter pname, int32* parameters) glGetTextureLevelParameteriv;
        public static function void(uint32 texture, GetTextureParameter pname, int32* parameters) glGetTextureParameterIiv;
        public static function void(uint32 texture, GetTextureParameter pname, uint32* parameters) glGetTextureParameterIuiv;
        public static function void(uint32 texture, GetTextureParameter pname, float* parameters) glGetTextureParameterfv;
        public static function void(uint32 texture, GetTextureParameter pname, int32* parameters) glGetTextureParameteriv;
        public static function void(uint32 texture, int32 level, int32 xoffset, int32 yoffset, int32 zoffset, int32 width, int32 height, int32 depth, PixelFormat format, PixelType type, int32 bufSize, void* pixels) glGetTextureSubImage;
        public static function void(uint32 program, uint32 index, int32 bufSize, int32* length, int32* size, AttributeType* type, char8* name) glGetTransformFeedbackVarying;
        public static function void(uint32 xfb, TransformFeedbackPName pname, uint32 index, int64* param) glGetTransformFeedbacki64_v;
        public static function void(uint32 xfb, TransformFeedbackPName pname, uint32 index, int32* param) glGetTransformFeedbacki_v;
        public static function void(uint32 xfb, TransformFeedbackPName pname, int32* param) glGetTransformFeedbackiv;
        public static function uint32(uint32 program, char8* uniformBlockName) glGetUniformBlockIndex;
        public static function void(uint32 program, int32 uniformCount, char8** uniformNames, uint32* uniformIndices) glGetUniformIndices;
        public static function int32(uint32 program, char8* name) glGetUniformLocation;
        public static function void(ShaderType shadertype, int32 location, uint32* parameters) glGetUniformSubroutineuiv;
        public static function void(uint32 program, int32 location, double* parameters) glGetUniformdv;
        public static function void(uint32 program, int32 location, float* parameters) glGetUniformfv;
        public static function void(uint32 program, int32 location, int32* parameters) glGetUniformiv;
        public static function void(uint32 program, int32 location, uint32* parameters) glGetUniformuiv;
        public static function void(uint32 vaobj, uint32 index, VertexArrayPName pname, int64* param) glGetVertexArrayIndexed64iv;
        public static function void(uint32 vaobj, uint32 index, VertexArrayPName pname, int32* param) glGetVertexArrayIndexediv;
        public static function void(uint32 vaobj, VertexArrayPName pname, int32* param) glGetVertexArrayiv;
        public static function void(uint32 index, VertexAttribEnum pname, int32* parameters) glGetVertexAttribIiv;
        public static function void(uint32 index, VertexAttribEnum pname, uint32* parameters) glGetVertexAttribIuiv;
        public static function void(uint32 index, VertexAttribEnum pname, double* parameters) glGetVertexAttribLdv;
        public static function void(uint32 index, VertexAttribPointerPropertyARB pname, void** pointer) glGetVertexAttribPointerv;
        public static function void(uint32 index, VertexAttribPropertyARB pname, double* parameters) glGetVertexAttribdv;
        public static function void(uint32 index, VertexAttribPropertyARB pname, float* parameters) glGetVertexAttribfv;
        public static function void(uint32 index, VertexAttribPropertyARB pname, int32* parameters) glGetVertexAttribiv;
        public static function void(ColorTableTarget target, PixelFormat format, PixelType type, int32 bufSize, void* table) glGetnColorTable;
        public static function void(TextureTarget target, int32 lod, int32 bufSize, void* pixels) glGetnCompressedTexImage;
        public static function void(ConvolutionTarget target, PixelFormat format, PixelType type, int32 bufSize, void* image) glGetnConvolutionFilter;
        public static function void(HistogramTarget target, Boolean reset, PixelFormat format, PixelType type, int32 bufSize, void* values) glGetnHistogram;
        public static function void(uint32 target, uint32 query, int32 bufSize, double* v) glGetnMapdv;
        public static function void(uint32 target, uint32 query, int32 bufSize, float* v) glGetnMapfv;
        public static function void(uint32 target, uint32 query, int32 bufSize, int32* v) glGetnMapiv;
        public static function void(MinmaxTarget target, Boolean reset, PixelFormat format, PixelType type, int32 bufSize, void* values) glGetnMinmax;
        public static function void(uint32 map, int32 bufSize, float* values) glGetnPixelMapfv;
        public static function void(uint32 map, int32 bufSize, uint32* values) glGetnPixelMapuiv;
        public static function void(uint32 map, int32 bufSize, uint16* values) glGetnPixelMapusv;
        public static function void(int32 bufSize, uint8* pattern) glGetnPolygonStipple;
        public static function void(SeparableTarget target, PixelFormat format, PixelType type, int32 rowBufSize, void* row, int32 columnBufSize, void* column, void* span) glGetnSeparableFilter;
        public static function void(TextureTarget target, int32 level, PixelFormat format, PixelType type, int32 bufSize, void* pixels) glGetnTexImage;
        public static function void(uint32 program, int32 location, int32 bufSize, double* parameters) glGetnUniformdv;
        public static function void(uint32 program, int32 location, int32 bufSize, float* parameters) glGetnUniformfv;
        public static function void(uint32 program, int32 location, int32 bufSize, int32* parameters) glGetnUniformiv;
        public static function void(uint32 program, int32 location, int32 bufSize, uint32* parameters) glGetnUniformuiv;
        public static function void(HintTarget target, HintMode mode) glHint;
        public static function void(uint32 buffer) glInvalidateBufferData;
        public static function void(uint32 buffer, int32 offset, int32 length) glInvalidateBufferSubData;
        public static function void(FramebufferTarget target, int32 numAttachments, InvalidateFramebufferAttachment* attachments) glInvalidateFramebuffer;
        public static function void(uint32 framebuffer, int32 numAttachments, FramebufferAttachment* attachments) glInvalidateNamedFramebufferData;
        public static function void(uint32 framebuffer, int32 numAttachments, FramebufferAttachment* attachments, int32 x, int32 y, int32 width, int32 height) glInvalidateNamedFramebufferSubData;
        public static function void(FramebufferTarget target, int32 numAttachments, InvalidateFramebufferAttachment* attachments, int32 x, int32 y, int32 width, int32 height) glInvalidateSubFramebuffer;
        public static function void(uint32 texture, int32 level) glInvalidateTexImage;
        public static function void(uint32 texture, int32 level, int32 xoffset, int32 yoffset, int32 zoffset, int32 width, int32 height, int32 depth) glInvalidateTexSubImage;
        public static function bool(uint32 buffer) glIsBuffer;
        public static function bool(EnableCap cap) glIsEnabled;
        public static function bool(EnableCap target, uint32 index) glIsEnabledi;
        public static function bool(uint32 framebuffer) glIsFramebuffer;
        public static function bool(uint32 program) glIsProgram;
        public static function bool(uint32 pipeline) glIsProgramPipeline;
        public static function bool(uint32 id) glIsQuery;
        public static function bool(uint32 renderbuffer) glIsRenderbuffer;
        public static function bool(uint32 sampler) glIsSampler;
        public static function bool(uint32 shader) glIsShader;
        public static function bool(void* sync) glIsSync;
        public static function bool(uint32 texture) glIsTexture;
        public static function bool(uint32 id) glIsTransformFeedback;
        public static function bool(uint32 array) glIsVertexArray;
        public static function void(float width) glLineWidth;
        public static function void(uint32 program) glLinkProgram;
        public static function void(LogicOp opcode) glLogicOp;
        public static function void*(BufferTargetARB target, BufferAccessARB access) glMapBuffer;
        public static function void*(BufferTargetARB target, int32 offset, int32 length, MapBufferAccessMask access) glMapBufferRange;
        public static function void*(uint32 buffer, BufferAccessARB access) glMapNamedBuffer;
        public static function void*(uint32 buffer, int32 offset, int32 length, MapBufferAccessMask access) glMapNamedBufferRange;
        public static function void(MemoryBarrierMask barriers) glMemoryBarrier;
        public static function void(MemoryBarrierMask barriers) glMemoryBarrierByRegion;
        public static function void(float value) glMinSampleShading;
        public static function void(PrimitiveType mode, int32* first, int32* count, int32 drawcount) glMultiDrawArrays;
        public static function void(PrimitiveType mode, void* indirect, int32 drawcount, int32 stride) glMultiDrawArraysIndirect;
        public static function void(PrimitiveType mode, int32* count, DrawElementsType type, void** indices, int32 drawcount) glMultiDrawElements;
        public static function void(PrimitiveType mode, int32* count, DrawElementsType type, void** indices, int32 drawcount, int32* basevertex) glMultiDrawElementsBaseVertex;
        public static function void(PrimitiveType mode, DrawElementsType type, void* indirect, int32 drawcount, int32 stride) glMultiDrawElementsIndirect;
        public static function void(TextureUnit texture, TexCoordPointerType type, uint32 coords) glMultiTexCoordP1ui;
        public static function void(TextureUnit texture, TexCoordPointerType type, uint32* coords) glMultiTexCoordP1uiv;
        public static function void(TextureUnit texture, TexCoordPointerType type, uint32 coords) glMultiTexCoordP2ui;
        public static function void(TextureUnit texture, TexCoordPointerType type, uint32* coords) glMultiTexCoordP2uiv;
        public static function void(TextureUnit texture, TexCoordPointerType type, uint32 coords) glMultiTexCoordP3ui;
        public static function void(TextureUnit texture, TexCoordPointerType type, uint32* coords) glMultiTexCoordP3uiv;
        public static function void(TextureUnit texture, TexCoordPointerType type, uint32 coords) glMultiTexCoordP4ui;
        public static function void(TextureUnit texture, TexCoordPointerType type, uint32* coords) glMultiTexCoordP4uiv;
        public static function void(uint32 buffer, int32 size, void* data, VertexBufferObjectUsage usage) glNamedBufferData;
        public static function void(uint32 buffer, int32 size, void* data, BufferStorageMask flags) glNamedBufferStorage;
        public static function void(uint32 buffer, int32 offset, int32 size, void* data) glNamedBufferSubData;
        public static function void(uint32 framebuffer, ColorBuffer buf) glNamedFramebufferDrawBuffer;
        public static function void(uint32 framebuffer, int32 n, ColorBuffer* bufs) glNamedFramebufferDrawBuffers;
        public static function void(uint32 framebuffer, FramebufferParameterName pname, int32 param) glNamedFramebufferParameteri;
        public static function void(uint32 framebuffer, ColorBuffer src) glNamedFramebufferReadBuffer;
        public static function void(uint32 framebuffer, FramebufferAttachment attachment, RenderbufferTarget renderbuffertarget, uint32 renderbuffer) glNamedFramebufferRenderbuffer;
        public static function void(uint32 framebuffer, FramebufferAttachment attachment, uint32 texture, int32 level) glNamedFramebufferTexture;
        public static function void(uint32 framebuffer, FramebufferAttachment attachment, uint32 texture, int32 level, int32 layer) glNamedFramebufferTextureLayer;
        public static function void(uint32 renderbuffer, InternalFormat internalformat, int32 width, int32 height) glNamedRenderbufferStorage;
        public static function void(uint32 renderbuffer, int32 samples, InternalFormat internalformat, int32 width, int32 height) glNamedRenderbufferStorageMultisample;
        public static function void(NormalPointerType type, uint32 coords) glNormalP3ui;
        public static function void(NormalPointerType type, uint32* coords) glNormalP3uiv;
        public static function void(ObjectIdentifier identifier, uint32 name, int32 length, char8* label) glObjectLabel;
        public static function void(void* ptr, int32 length, char8* label) glObjectPtrLabel;
        public static function void(PatchParameterName pname, float* values) glPatchParameterfv;
        public static function void(PatchParameterName pname, int32 value) glPatchParameteri;
        public static function void() glPauseTransformFeedback;
        public static function void(PixelStoreParameter pname, float param) glPixelStoref;
        public static function void(PixelStoreParameter pname, int32 param) glPixelStorei;
        public static function void(PointParameterNameARB pname, float param) glPointParameterf;
        public static function void(PointParameterNameARB pname, float* parameters) glPointParameterfv;
        public static function void(PointParameterNameARB pname, int32 param) glPointParameteri;
        public static function void(PointParameterNameARB pname, int32* parameters) glPointParameteriv;
        public static function void(float size) glPointSize;
        public static function void(MaterialFace face, PolygonMode mode) glPolygonMode;
        public static function void(float factor, float units) glPolygonOffset;
        public static function void() glPopDebugGroup;
        public static function void(uint32 index) glPrimitiveRestartIndex;
        public static function void(uint32 program, uint32 binaryFormat, void* binary, int32 length) glProgramBinary;
        public static function void(uint32 program, ProgramParameterPName pname, int32 value) glProgramParameteri;
        public static function void(uint32 program, int32 location, double v0) glProgramUniform1d;
        public static function void(uint32 program, int32 location, int32 count, double* value) glProgramUniform1dv;
        public static function void(uint32 program, int32 location, float v0) glProgramUniform1f;
        public static function void(uint32 program, int32 location, int32 count, float* value) glProgramUniform1fv;
        public static function void(uint32 program, int32 location, int32 v0) glProgramUniform1i;
        public static function void(uint32 program, int32 location, int32 count, int32* value) glProgramUniform1iv;
        public static function void(uint32 program, int32 location, uint32 v0) glProgramUniform1ui;
        public static function void(uint32 program, int32 location, int32 count, uint32* value) glProgramUniform1uiv;
        public static function void(uint32 program, int32 location, double v0, double v1) glProgramUniform2d;
        public static function void(uint32 program, int32 location, int32 count, double* value) glProgramUniform2dv;
        public static function void(uint32 program, int32 location, float v0, float v1) glProgramUniform2f;
        public static function void(uint32 program, int32 location, int32 count, float* value) glProgramUniform2fv;
        public static function void(uint32 program, int32 location, int32 v0, int32 v1) glProgramUniform2i;
        public static function void(uint32 program, int32 location, int32 count, int32* value) glProgramUniform2iv;
        public static function void(uint32 program, int32 location, uint32 v0, uint32 v1) glProgramUniform2ui;
        public static function void(uint32 program, int32 location, int32 count, uint32* value) glProgramUniform2uiv;
        public static function void(uint32 program, int32 location, double v0, double v1, double v2) glProgramUniform3d;
        public static function void(uint32 program, int32 location, int32 count, double* value) glProgramUniform3dv;
        public static function void(uint32 program, int32 location, float v0, float v1, float v2) glProgramUniform3f;
        public static function void(uint32 program, int32 location, int32 count, float* value) glProgramUniform3fv;
        public static function void(uint32 program, int32 location, int32 v0, int32 v1, int32 v2) glProgramUniform3i;
        public static function void(uint32 program, int32 location, int32 count, int32* value) glProgramUniform3iv;
        public static function void(uint32 program, int32 location, uint32 v0, uint32 v1, uint32 v2) glProgramUniform3ui;
        public static function void(uint32 program, int32 location, int32 count, uint32* value) glProgramUniform3uiv;
        public static function void(uint32 program, int32 location, double v0, double v1, double v2, double v3) glProgramUniform4d;
        public static function void(uint32 program, int32 location, int32 count, double* value) glProgramUniform4dv;
        public static function void(uint32 program, int32 location, float v0, float v1, float v2, float v3) glProgramUniform4f;
        public static function void(uint32 program, int32 location, int32 count, float* value) glProgramUniform4fv;
        public static function void(uint32 program, int32 location, int32 v0, int32 v1, int32 v2, int32 v3) glProgramUniform4i;
        public static function void(uint32 program, int32 location, int32 count, int32* value) glProgramUniform4iv;
        public static function void(uint32 program, int32 location, uint32 v0, uint32 v1, uint32 v2, uint32 v3) glProgramUniform4ui;
        public static function void(uint32 program, int32 location, int32 count, uint32* value) glProgramUniform4uiv;
        public static function void(uint32 program, int32 location, int32 count, Boolean transpose, double* value) glProgramUniformMatrix2dv;
        public static function void(uint32 program, int32 location, int32 count, Boolean transpose, float* value) glProgramUniformMatrix2fv;
        public static function void(uint32 program, int32 location, int32 count, Boolean transpose, double* value) glProgramUniformMatrix2x3dv;
        public static function void(uint32 program, int32 location, int32 count, Boolean transpose, float* value) glProgramUniformMatrix2x3fv;
        public static function void(uint32 program, int32 location, int32 count, Boolean transpose, double* value) glProgramUniformMatrix2x4dv;
        public static function void(uint32 program, int32 location, int32 count, Boolean transpose, float* value) glProgramUniformMatrix2x4fv;
        public static function void(uint32 program, int32 location, int32 count, Boolean transpose, double* value) glProgramUniformMatrix3dv;
        public static function void(uint32 program, int32 location, int32 count, Boolean transpose, float* value) glProgramUniformMatrix3fv;
        public static function void(uint32 program, int32 location, int32 count, Boolean transpose, double* value) glProgramUniformMatrix3x2dv;
        public static function void(uint32 program, int32 location, int32 count, Boolean transpose, float* value) glProgramUniformMatrix3x2fv;
        public static function void(uint32 program, int32 location, int32 count, Boolean transpose, double* value) glProgramUniformMatrix3x4dv;
        public static function void(uint32 program, int32 location, int32 count, Boolean transpose, float* value) glProgramUniformMatrix3x4fv;
        public static function void(uint32 program, int32 location, int32 count, Boolean transpose, double* value) glProgramUniformMatrix4dv;
        public static function void(uint32 program, int32 location, int32 count, Boolean transpose, float* value) glProgramUniformMatrix4fv;
        public static function void(uint32 program, int32 location, int32 count, Boolean transpose, double* value) glProgramUniformMatrix4x2dv;
        public static function void(uint32 program, int32 location, int32 count, Boolean transpose, float* value) glProgramUniformMatrix4x2fv;
        public static function void(uint32 program, int32 location, int32 count, Boolean transpose, double* value) glProgramUniformMatrix4x3dv;
        public static function void(uint32 program, int32 location, int32 count, Boolean transpose, float* value) glProgramUniformMatrix4x3fv;
        public static function void(VertexProvokingMode mode) glProvokingVertex;
        public static function void(DebugSource source, uint32 id, int32 length, char8* message) glPushDebugGroup;
        public static function void(uint32 id, QueryCounterTarget target) glQueryCounter;
        public static function void(ReadBufferMode src) glReadBuffer;
        public static function void(int32 x, int32 y, int32 width, int32 height, PixelFormat format, PixelType type, void* pixels) glReadPixels;
        public static function void(int32 x, int32 y, int32 width, int32 height, PixelFormat format, PixelType type, int32 bufSize, void* data) glReadnPixels;
        public static function void() glReleaseShaderCompiler;
        public static function void(RenderbufferTarget target, InternalFormat internalformat, int32 width, int32 height) glRenderbufferStorage;
        public static function void(RenderbufferTarget target, int32 samples, InternalFormat internalformat, int32 width, int32 height) glRenderbufferStorageMultisample;
        public static function void() glResumeTransformFeedback;
        public static function void(float value, Boolean invert) glSampleCoverage;
        public static function void(uint32 maskNumber, uint32 mask) glSampleMaski;
        public static function void(uint32 sampler, SamplerParameterI pname, int32* param) glSamplerParameterIiv;
        public static function void(uint32 sampler, SamplerParameterI pname, uint32* param) glSamplerParameterIuiv;
        public static function void(uint32 sampler, SamplerParameterF pname, float param) glSamplerParameterf;
        public static function void(uint32 sampler, SamplerParameterF pname, float* param) glSamplerParameterfv;
        public static function void(uint32 sampler, SamplerParameterI pname, int32 param) glSamplerParameteri;
        public static function void(uint32 sampler, SamplerParameterI pname, int32* param) glSamplerParameteriv;
        public static function void(int32 x, int32 y, int32 width, int32 height) glScissor;
        public static function void(uint32 first, int32 count, int32* v) glScissorArrayv;
        public static function void(uint32 index, int32 left, int32 bottom, int32 width, int32 height) glScissorIndexed;
        public static function void(uint32 index, int32* v) glScissorIndexedv;
        public static function void(ColorPointerType type, uint32 color) glSecondaryColorP3ui;
        public static function void(ColorPointerType type, uint32* color) glSecondaryColorP3uiv;
        public static function void(int32 count, uint32* shaders, uint32 binaryFormat, void* binary, int32 length) glShaderBinary;
        public static function void(uint32 shader, int32 count, char8** string, int32* length) glShaderSource;
        public static function void(uint32 program, uint32 storageBlockIndex, uint32 storageBlockBinding) glShaderStorageBlockBinding;
        public static function void(StencilFunction func, int32 reference, uint32 mask) glStencilFunc;
        public static function void(StencilFaceDirection face, StencilFunction func, int32 reference, uint32 mask) glStencilFuncSeparate;
        public static function void(uint32 mask) glStencilMask;
        public static function void(StencilFaceDirection face, uint32 mask) glStencilMaskSeparate;
        public static function void(StencilOp fail, StencilOp zfail, StencilOp zpass) glStencilOp;
        public static function void(StencilFaceDirection face, StencilOp sfail, StencilOp dpfail, StencilOp dppass) glStencilOpSeparate;
        public static function void(TextureTarget target, SizedInternalFormat internalformat, uint32 buffer) glTexBuffer;
        public static function void(TextureTarget target, SizedInternalFormat internalformat, uint32 buffer, int32 offset, int32 size) glTexBufferRange;
        public static function void(TexCoordPointerType type, uint32 coords) glTexCoordP1ui;
        public static function void(TexCoordPointerType type, uint32* coords) glTexCoordP1uiv;
        public static function void(TexCoordPointerType type, uint32 coords) glTexCoordP2ui;
        public static function void(TexCoordPointerType type, uint32* coords) glTexCoordP2uiv;
        public static function void(TexCoordPointerType type, uint32 coords) glTexCoordP3ui;
        public static function void(TexCoordPointerType type, uint32* coords) glTexCoordP3uiv;
        public static function void(TexCoordPointerType type, uint32 coords) glTexCoordP4ui;
        public static function void(TexCoordPointerType type, uint32* coords) glTexCoordP4uiv;
        public static function void(TextureTarget target, int32 level, InternalFormat internalformat, int32 width, int32 border, PixelFormat format, PixelType type, void* pixels) glTexImage1D;
        public static function void(TextureTarget target, int32 level, InternalFormat internalformat, int32 width, int32 height, int32 border, PixelFormat format, PixelType type, void* pixels) glTexImage2D;
        public static function void(TextureTarget target, int32 samples, InternalFormat internalformat, int32 width, int32 height, Boolean fixedsamplelocations) glTexImage2DMultisample;
        public static function void(TextureTarget target, int32 level, InternalFormat internalformat, int32 width, int32 height, int32 depth, int32 border, PixelFormat format, PixelType type, void* pixels) glTexImage3D;
        public static function void(TextureTarget target, int32 samples, InternalFormat internalformat, int32 width, int32 height, int32 depth, Boolean fixedsamplelocations) glTexImage3DMultisample;
        public static function void(TextureTarget target, TextureParameterName pname, int32* parameters) glTexParameterIiv;
        public static function void(TextureTarget target, TextureParameterName pname, uint32* parameters) glTexParameterIuiv;
        public static function void(TextureTarget target, TextureParameterName pname, float param) glTexParameterf;
        public static function void(TextureTarget target, TextureParameterName pname, float* parameters) glTexParameterfv;
        public static function void(TextureTarget target, TextureParameterName pname, int32 param) glTexParameteri;
        public static function void(TextureTarget target, TextureParameterName pname, int32* parameters) glTexParameteriv;
        public static function void(TextureTarget target, int32 levels, SizedInternalFormat internalformat, int32 width) glTexStorage1D;
        public static function void(TextureTarget target, int32 levels, SizedInternalFormat internalformat, int32 width, int32 height) glTexStorage2D;
        public static function void(TextureTarget target, int32 samples, SizedInternalFormat internalformat, int32 width, int32 height, Boolean fixedsamplelocations) glTexStorage2DMultisample;
        public static function void(TextureTarget target, int32 levels, SizedInternalFormat internalformat, int32 width, int32 height, int32 depth) glTexStorage3D;
        public static function void(TextureTarget target, int32 samples, SizedInternalFormat internalformat, int32 width, int32 height, int32 depth, Boolean fixedsamplelocations) glTexStorage3DMultisample;
        public static function void(TextureTarget target, int32 level, int32 xoffset, int32 width, PixelFormat format, PixelType type, void* pixels) glTexSubImage1D;
        public static function void(TextureTarget target, int32 level, int32 xoffset, int32 yoffset, int32 width, int32 height, PixelFormat format, PixelType type, void* pixels) glTexSubImage2D;
        public static function void(TextureTarget target, int32 level, int32 xoffset, int32 yoffset, int32 zoffset, int32 width, int32 height, int32 depth, PixelFormat format, PixelType type, void* pixels) glTexSubImage3D;
        public static function void() glTextureBarrier;
        public static function void(uint32 texture, SizedInternalFormat internalformat, uint32 buffer) glTextureBuffer;
        public static function void(uint32 texture, SizedInternalFormat internalformat, uint32 buffer, int32 offset, int32 size) glTextureBufferRange;
        public static function void(uint32 texture, TextureParameterName pname, int32* parameters) glTextureParameterIiv;
        public static function void(uint32 texture, TextureParameterName pname, uint32* parameters) glTextureParameterIuiv;
        public static function void(uint32 texture, TextureParameterName pname, float param) glTextureParameterf;
        public static function void(uint32 texture, TextureParameterName pname, float* param) glTextureParameterfv;
        public static function void(uint32 texture, TextureParameterName pname, int32 param) glTextureParameteri;
        public static function void(uint32 texture, TextureParameterName pname, int32* param) glTextureParameteriv;
        public static function void(uint32 texture, int32 levels, SizedInternalFormat internalformat, int32 width) glTextureStorage1D;
        public static function void(uint32 texture, int32 levels, SizedInternalFormat internalformat, int32 width, int32 height) glTextureStorage2D;
        public static function void(uint32 texture, int32 samples, SizedInternalFormat internalformat, int32 width, int32 height, Boolean fixedsamplelocations) glTextureStorage2DMultisample;
        public static function void(uint32 texture, int32 levels, SizedInternalFormat internalformat, int32 width, int32 height, int32 depth) glTextureStorage3D;
        public static function void(uint32 texture, int32 samples, SizedInternalFormat internalformat, int32 width, int32 height, int32 depth, Boolean fixedsamplelocations) glTextureStorage3DMultisample;
        public static function void(uint32 texture, int32 level, int32 xoffset, int32 width, PixelFormat format, PixelType type, void* pixels) glTextureSubImage1D;
        public static function void(uint32 texture, int32 level, int32 xoffset, int32 yoffset, int32 width, int32 height, PixelFormat format, PixelType type, void* pixels) glTextureSubImage2D;
        public static function void(uint32 texture, int32 level, int32 xoffset, int32 yoffset, int32 zoffset, int32 width, int32 height, int32 depth, PixelFormat format, PixelType type, void* pixels) glTextureSubImage3D;
        public static function void(uint32 texture, TextureTarget target, uint32 origtexture, SizedInternalFormat internalformat, uint32 minlevel, uint32 numlevels, uint32 minlayer, uint32 numlayers) glTextureView;
        public static function void(uint32 xfb, uint32 index, uint32 buffer) glTransformFeedbackBufferBase;
        public static function void(uint32 xfb, uint32 index, uint32 buffer, int32 offset, int32 size) glTransformFeedbackBufferRange;
        public static function void(uint32 program, int32 count, char8** varyings, TransformFeedbackBufferMode bufferMode) glTransformFeedbackVaryings;
        public static function void(int32 location, double x) glUniform1d;
        public static function void(int32 location, int32 count, double* value) glUniform1dv;
        public static function void(int32 location, float v0) glUniform1f;
        public static function void(int32 location, int32 count, float* value) glUniform1fv;
        public static function void(int32 location, int32 v0) glUniform1i;
        public static function void(int32 location, int32 count, int32* value) glUniform1iv;
        public static function void(int32 location, uint32 v0) glUniform1ui;
        public static function void(int32 location, int32 count, uint32* value) glUniform1uiv;
        public static function void(int32 location, double x, double y) glUniform2d;
        public static function void(int32 location, int32 count, double* value) glUniform2dv;
        public static function void(int32 location, float v0, float v1) glUniform2f;
        public static function void(int32 location, int32 count, float* value) glUniform2fv;
        public static function void(int32 location, int32 v0, int32 v1) glUniform2i;
        public static function void(int32 location, int32 count, int32* value) glUniform2iv;
        public static function void(int32 location, uint32 v0, uint32 v1) glUniform2ui;
        public static function void(int32 location, int32 count, uint32* value) glUniform2uiv;
        public static function void(int32 location, double x, double y, double z) glUniform3d;
        public static function void(int32 location, int32 count, double* value) glUniform3dv;
        public static function void(int32 location, float v0, float v1, float v2) glUniform3f;
        public static function void(int32 location, int32 count, float* value) glUniform3fv;
        public static function void(int32 location, int32 v0, int32 v1, int32 v2) glUniform3i;
        public static function void(int32 location, int32 count, int32* value) glUniform3iv;
        public static function void(int32 location, uint32 v0, uint32 v1, uint32 v2) glUniform3ui;
        public static function void(int32 location, int32 count, uint32* value) glUniform3uiv;
        public static function void(int32 location, double x, double y, double z, double w) glUniform4d;
        public static function void(int32 location, int32 count, double* value) glUniform4dv;
        public static function void(int32 location, float v0, float v1, float v2, float v3) glUniform4f;
        public static function void(int32 location, int32 count, float* value) glUniform4fv;
        public static function void(int32 location, int32 v0, int32 v1, int32 v2, int32 v3) glUniform4i;
        public static function void(int32 location, int32 count, int32* value) glUniform4iv;
        public static function void(int32 location, uint32 v0, uint32 v1, uint32 v2, uint32 v3) glUniform4ui;
        public static function void(int32 location, int32 count, uint32* value) glUniform4uiv;
        public static function void(uint32 program, uint32 uniformBlockIndex, uint32 uniformBlockBinding) glUniformBlockBinding;
        public static function void(int32 location, int32 count, Boolean transpose, double* value) glUniformMatrix2dv;
        public static function void(int32 location, int32 count, Boolean transpose, float* value) glUniformMatrix2fv;
        public static function void(int32 location, int32 count, Boolean transpose, double* value) glUniformMatrix2x3dv;
        public static function void(int32 location, int32 count, Boolean transpose, float* value) glUniformMatrix2x3fv;
        public static function void(int32 location, int32 count, Boolean transpose, double* value) glUniformMatrix2x4dv;
        public static function void(int32 location, int32 count, Boolean transpose, float* value) glUniformMatrix2x4fv;
        public static function void(int32 location, int32 count, Boolean transpose, double* value) glUniformMatrix3dv;
        public static function void(int32 location, int32 count, Boolean transpose, float* value) glUniformMatrix3fv;
        public static function void(int32 location, int32 count, Boolean transpose, double* value) glUniformMatrix3x2dv;
        public static function void(int32 location, int32 count, Boolean transpose, float* value) glUniformMatrix3x2fv;
        public static function void(int32 location, int32 count, Boolean transpose, double* value) glUniformMatrix3x4dv;
        public static function void(int32 location, int32 count, Boolean transpose, float* value) glUniformMatrix3x4fv;
        public static function void(int32 location, int32 count, Boolean transpose, double* value) glUniformMatrix4dv;
        public static function void(int32 location, int32 count, Boolean transpose, float* value) glUniformMatrix4fv;
        public static function void(int32 location, int32 count, Boolean transpose, double* value) glUniformMatrix4x2dv;
        public static function void(int32 location, int32 count, Boolean transpose, float* value) glUniformMatrix4x2fv;
        public static function void(int32 location, int32 count, Boolean transpose, double* value) glUniformMatrix4x3dv;
        public static function void(int32 location, int32 count, Boolean transpose, float* value) glUniformMatrix4x3fv;
        public static function void(ShaderType shadertype, int32 count, uint32* indices) glUniformSubroutinesuiv;
        public static function bool(BufferTargetARB target) glUnmapBuffer;
        public static function bool(uint32 buffer) glUnmapNamedBuffer;
        public static function void(uint32 program) glUseProgram;
        public static function void(uint32 pipeline, UseProgramStageMask stages, uint32 program) glUseProgramStages;
        public static function void(uint32 program) glValidateProgram;
        public static function void(uint32 pipeline) glValidateProgramPipeline;
        public static function void(uint32 vaobj, uint32 attribindex, uint32 bindingindex) glVertexArrayAttribBinding;
        public static function void(uint32 vaobj, uint32 attribindex, int32 size, VertexAttribType type, Boolean normalized, uint32 relativeoffset) glVertexArrayAttribFormat;
        public static function void(uint32 vaobj, uint32 attribindex, int32 size, VertexAttribIType type, uint32 relativeoffset) glVertexArrayAttribIFormat;
        public static function void(uint32 vaobj, uint32 attribindex, int32 size, VertexAttribLType type, uint32 relativeoffset) glVertexArrayAttribLFormat;
        public static function void(uint32 vaobj, uint32 bindingindex, uint32 divisor) glVertexArrayBindingDivisor;
        public static function void(uint32 vaobj, uint32 buffer) glVertexArrayElementBuffer;
        public static function void(uint32 vaobj, uint32 bindingindex, uint32 buffer, int32 offset, int32 stride) glVertexArrayVertexBuffer;
        public static function void(uint32 vaobj, uint32 first, int32 count, uint32* buffers, int32* offsets, int32* strides) glVertexArrayVertexBuffers;
        public static function void(uint32 index, double x) glVertexAttrib1d;
        public static function void(uint32 index, double* v) glVertexAttrib1dv;
        public static function void(uint32 index, float x) glVertexAttrib1f;
        public static function void(uint32 index, float* v) glVertexAttrib1fv;
        public static function void(uint32 index, int16 x) glVertexAttrib1s;
        public static function void(uint32 index, int16* v) glVertexAttrib1sv;
        public static function void(uint32 index, double x, double y) glVertexAttrib2d;
        public static function void(uint32 index, double* v) glVertexAttrib2dv;
        public static function void(uint32 index, float x, float y) glVertexAttrib2f;
        public static function void(uint32 index, float* v) glVertexAttrib2fv;
        public static function void(uint32 index, int16 x, int16 y) glVertexAttrib2s;
        public static function void(uint32 index, int16* v) glVertexAttrib2sv;
        public static function void(uint32 index, double x, double y, double z) glVertexAttrib3d;
        public static function void(uint32 index, double* v) glVertexAttrib3dv;
        public static function void(uint32 index, float x, float y, float z) glVertexAttrib3f;
        public static function void(uint32 index, float* v) glVertexAttrib3fv;
        public static function void(uint32 index, int16 x, int16 y, int16 z) glVertexAttrib3s;
        public static function void(uint32 index, int16* v) glVertexAttrib3sv;
        public static function void(uint32 index, int8* v) glVertexAttrib4Nbv;
        public static function void(uint32 index, int32* v) glVertexAttrib4Niv;
        public static function void(uint32 index, int16* v) glVertexAttrib4Nsv;
        public static function void(uint32 index, uint8 x, uint8 y, uint8 z, uint8 w) glVertexAttrib4Nub;
        public static function void(uint32 index, uint8* v) glVertexAttrib4Nubv;
        public static function void(uint32 index, uint32* v) glVertexAttrib4Nuiv;
        public static function void(uint32 index, uint16* v) glVertexAttrib4Nusv;
        public static function void(uint32 index, int8* v) glVertexAttrib4bv;
        public static function void(uint32 index, double x, double y, double z, double w) glVertexAttrib4d;
        public static function void(uint32 index, double* v) glVertexAttrib4dv;
        public static function void(uint32 index, float x, float y, float z, float w) glVertexAttrib4f;
        public static function void(uint32 index, float* v) glVertexAttrib4fv;
        public static function void(uint32 index, int32* v) glVertexAttrib4iv;
        public static function void(uint32 index, int16 x, int16 y, int16 z, int16 w) glVertexAttrib4s;
        public static function void(uint32 index, int16* v) glVertexAttrib4sv;
        public static function void(uint32 index, uint8* v) glVertexAttrib4ubv;
        public static function void(uint32 index, uint32* v) glVertexAttrib4uiv;
        public static function void(uint32 index, uint16* v) glVertexAttrib4usv;
        public static function void(uint32 attribindex, uint32 bindingindex) glVertexAttribBinding;
        public static function void(uint32 index, uint32 divisor) glVertexAttribDivisor;
        public static function void(uint32 attribindex, int32 size, VertexAttribType type, Boolean normalized, uint32 relativeoffset) glVertexAttribFormat;
        public static function void(uint32 index, int32 x) glVertexAttribI1i;
        public static function void(uint32 index, int32* v) glVertexAttribI1iv;
        public static function void(uint32 index, uint32 x) glVertexAttribI1ui;
        public static function void(uint32 index, uint32* v) glVertexAttribI1uiv;
        public static function void(uint32 index, int32 x, int32 y) glVertexAttribI2i;
        public static function void(uint32 index, int32* v) glVertexAttribI2iv;
        public static function void(uint32 index, uint32 x, uint32 y) glVertexAttribI2ui;
        public static function void(uint32 index, uint32* v) glVertexAttribI2uiv;
        public static function void(uint32 index, int32 x, int32 y, int32 z) glVertexAttribI3i;
        public static function void(uint32 index, int32* v) glVertexAttribI3iv;
        public static function void(uint32 index, uint32 x, uint32 y, uint32 z) glVertexAttribI3ui;
        public static function void(uint32 index, uint32* v) glVertexAttribI3uiv;
        public static function void(uint32 index, int8* v) glVertexAttribI4bv;
        public static function void(uint32 index, int32 x, int32 y, int32 z, int32 w) glVertexAttribI4i;
        public static function void(uint32 index, int32* v) glVertexAttribI4iv;
        public static function void(uint32 index, int16* v) glVertexAttribI4sv;
        public static function void(uint32 index, uint8* v) glVertexAttribI4ubv;
        public static function void(uint32 index, uint32 x, uint32 y, uint32 z, uint32 w) glVertexAttribI4ui;
        public static function void(uint32 index, uint32* v) glVertexAttribI4uiv;
        public static function void(uint32 index, uint16* v) glVertexAttribI4usv;
        public static function void(uint32 attribindex, int32 size, VertexAttribIType type, uint32 relativeoffset) glVertexAttribIFormat;
        public static function void(uint32 index, int32 size, VertexAttribIType type, int32 stride, void* pointer) glVertexAttribIPointer;
        public static function void(uint32 index, double x) glVertexAttribL1d;
        public static function void(uint32 index, double* v) glVertexAttribL1dv;
        public static function void(uint32 index, double x, double y) glVertexAttribL2d;
        public static function void(uint32 index, double* v) glVertexAttribL2dv;
        public static function void(uint32 index, double x, double y, double z) glVertexAttribL3d;
        public static function void(uint32 index, double* v) glVertexAttribL3dv;
        public static function void(uint32 index, double x, double y, double z, double w) glVertexAttribL4d;
        public static function void(uint32 index, double* v) glVertexAttribL4dv;
        public static function void(uint32 attribindex, int32 size, VertexAttribLType type, uint32 relativeoffset) glVertexAttribLFormat;
        public static function void(uint32 index, int32 size, VertexAttribLType type, int32 stride, void* pointer) glVertexAttribLPointer;
        public static function void(uint32 index, VertexAttribPointerType type, Boolean normalized, uint32 value) glVertexAttribP1ui;
        public static function void(uint32 index, VertexAttribPointerType type, Boolean normalized, uint32* value) glVertexAttribP1uiv;
        public static function void(uint32 index, VertexAttribPointerType type, Boolean normalized, uint32 value) glVertexAttribP2ui;
        public static function void(uint32 index, VertexAttribPointerType type, Boolean normalized, uint32* value) glVertexAttribP2uiv;
        public static function void(uint32 index, VertexAttribPointerType type, Boolean normalized, uint32 value) glVertexAttribP3ui;
        public static function void(uint32 index, VertexAttribPointerType type, Boolean normalized, uint32* value) glVertexAttribP3uiv;
        public static function void(uint32 index, VertexAttribPointerType type, Boolean normalized, uint32 value) glVertexAttribP4ui;
        public static function void(uint32 index, VertexAttribPointerType type, Boolean normalized, uint32* value) glVertexAttribP4uiv;
        public static function void(uint32 index, int32 size, VertexAttribPointerType type, Boolean normalized, int32 stride, void* pointer) glVertexAttribPointer;
        public static function void(uint32 bindingindex, uint32 divisor) glVertexBindingDivisor;
        public static function void(VertexPointerType type, uint32 value) glVertexP2ui;
        public static function void(VertexPointerType type, uint32* value) glVertexP2uiv;
        public static function void(VertexPointerType type, uint32 value) glVertexP3ui;
        public static function void(VertexPointerType type, uint32* value) glVertexP3uiv;
        public static function void(VertexPointerType type, uint32 value) glVertexP4ui;
        public static function void(VertexPointerType type, uint32* value) glVertexP4uiv;
        public static function void(int32 x, int32 y, int32 width, int32 height) glViewport;
        public static function void(uint32 first, int32 count, float* v) glViewportArrayv;
        public static function void(uint32 index, float x, float y, float w, float h) glViewportIndexedf;
        public static function void(uint32 index, float* v) glViewportIndexedfv;
        public static function void(void* sync, SyncBehaviorFlags flags, uint64 timeout) glWaitSync;

        public static void Init(function void*(StringView procname) func) {
            glVertexAttrib4Nub = (.)func("glVertexAttrib4Nub");
            glPointParameteriv = (.)func("glPointParameteriv");
            glVertexP2ui = (.)func("glVertexP2ui");
            glVertexAttribI4uiv = (.)func("glVertexAttribI4uiv");
            glIsQuery = (.)func("glIsQuery");
            glIsVertexArray = (.)func("glIsVertexArray");
            glNamedFramebufferParameteri = (.)func("glNamedFramebufferParameteri");
            glUniform1iv = (.)func("glUniform1iv");
            glGetnUniformfv = (.)func("glGetnUniformfv");
            glNamedBufferData = (.)func("glNamedBufferData");
            glPushDebugGroup = (.)func("glPushDebugGroup");
            glGetNamedFramebufferAttachmentParameteriv = (.)func("glGetNamedFramebufferAttachmentParameteriv");
            glLineWidth = (.)func("glLineWidth");
            glGetTextureSubImage = (.)func("glGetTextureSubImage");
            glGetnMinmax = (.)func("glGetnMinmax");
            glClearBufferfv = (.)func("glClearBufferfv");
            glFenceSync = (.)func("glFenceSync");
            glGetSamplerParameterfv = (.)func("glGetSamplerParameterfv");
            glBindAttribLocation = (.)func("glBindAttribLocation");
            glVertexAttrib4Nsv = (.)func("glVertexAttrib4Nsv");
            glBindRenderbuffer = (.)func("glBindRenderbuffer");
            glProgramUniform3uiv = (.)func("glProgramUniform3uiv");
            glInvalidateNamedFramebufferSubData = (.)func("glInvalidateNamedFramebufferSubData");
            glInvalidateNamedFramebufferData = (.)func("glInvalidateNamedFramebufferData");
            glVertexAttrib3sv = (.)func("glVertexAttrib3sv");
            glUseProgramStages = (.)func("glUseProgramStages");
            glClearBufferfi = (.)func("glClearBufferfi");
            glVertexAttribPointer = (.)func("glVertexAttribPointer");
            glGetQueryBufferObjectiv = (.)func("glGetQueryBufferObjectiv");
            glGetTexLevelParameterfv = (.)func("glGetTexLevelParameterfv");
            glClampColor = (.)func("glClampColor");
            glGetTransformFeedbacki_v = (.)func("glGetTransformFeedbacki_v");
            glGetVertexArrayiv = (.)func("glGetVertexArrayiv");
            glClearBufferiv = (.)func("glClearBufferiv");
            glScissorArrayv = (.)func("glScissorArrayv");
            glCopyNamedBufferSubData = (.)func("glCopyNamedBufferSubData");
            glVertexAttrib4Nubv = (.)func("glVertexAttrib4Nubv");
            glDeleteTransformFeedbacks = (.)func("glDeleteTransformFeedbacks");
            glVertexAttrib4ubv = (.)func("glVertexAttrib4ubv");
            glGetProgramResourceIndex = (.)func("glGetProgramResourceIndex");
            glUniform4uiv = (.)func("glUniform4uiv");
            glPolygonMode = (.)func("glPolygonMode");
            glCompressedTexSubImage2D = (.)func("glCompressedTexSubImage2D");
            glSampleMaski = (.)func("glSampleMaski");
            glNormalP3uiv = (.)func("glNormalP3uiv");
            glVertexAttribP4uiv = (.)func("glVertexAttribP4uiv");
            glProgramUniform1iv = (.)func("glProgramUniform1iv");
            glDrawElements = (.)func("glDrawElements");
            glGetStringi = (.)func("glGetStringi");
            glGetTextureParameterIuiv = (.)func("glGetTextureParameterIuiv");
            glClearNamedBufferData = (.)func("glClearNamedBufferData");
            glPointParameterfv = (.)func("glPointParameterfv");
            glGetUniformLocation = (.)func("glGetUniformLocation");
            glGetTextureParameterfv = (.)func("glGetTextureParameterfv");
            glInvalidateSubFramebuffer = (.)func("glInvalidateSubFramebuffer");
            glVertexP3ui = (.)func("glVertexP3ui");
            glVertexAttrib4sv = (.)func("glVertexAttrib4sv");
            glGetTexParameteriv = (.)func("glGetTexParameteriv");
            glBindVertexBuffers = (.)func("glBindVertexBuffers");
            glTextureParameterIiv = (.)func("glTextureParameterIiv");
            glVertexAttribI4bv = (.)func("glVertexAttribI4bv");
            glGetSamplerParameteriv = (.)func("glGetSamplerParameteriv");
            glCompressedTexSubImage1D = (.)func("glCompressedTexSubImage1D");
            glBindImageTextures = (.)func("glBindImageTextures");
            glBlendFunc = (.)func("glBlendFunc");
            glBindProgramPipeline = (.)func("glBindProgramPipeline");
            glCreateFramebuffers = (.)func("glCreateFramebuffers");
            glVertexAttribIFormat = (.)func("glVertexAttribIFormat");
            glUniform3iv = (.)func("glUniform3iv");
            glUniform2d = (.)func("glUniform2d");
            glUniform2f = (.)func("glUniform2f");
            glDrawElementsInstancedBaseVertex = (.)func("glDrawElementsInstancedBaseVertex");
            glGetMultisamplefv = (.)func("glGetMultisamplefv");
            glGetnMapfv = (.)func("glGetnMapfv");
            glGetInternalformativ = (.)func("glGetInternalformativ");
            glUniform2i = (.)func("glUniform2i");
            glBufferSubData = (.)func("glBufferSubData");
            glCreateQueries = (.)func("glCreateQueries");
            glProgramUniform4i = (.)func("glProgramUniform4i");
            glCreateTransformFeedbacks = (.)func("glCreateTransformFeedbacks");
            glGenVertexArrays = (.)func("glGenVertexArrays");
            glClearBufferSubData = (.)func("glClearBufferSubData");
            glProgramUniform4d = (.)func("glProgramUniform4d");
            glBindSampler = (.)func("glBindSampler");
            glProgramUniform4ui = (.)func("glProgramUniform4ui");
            glProgramUniform4f = (.)func("glProgramUniform4f");
            glIsEnabled = (.)func("glIsEnabled");
            glGetCompressedTextureSubImage = (.)func("glGetCompressedTextureSubImage");
            glEnableVertexAttribArray = (.)func("glEnableVertexAttribArray");
            glProvokingVertex = (.)func("glProvokingVertex");
            glEnableVertexArrayAttrib = (.)func("glEnableVertexArrayAttrib");
            glDeleteProgram = (.)func("glDeleteProgram");
            glVertexAttribP2uiv = (.)func("glVertexAttribP2uiv");
            glGenFramebuffers = (.)func("glGenFramebuffers");
            glUniform3d = (.)func("glUniform3d");
            glUniform3f = (.)func("glUniform3f");
            glUniform2fv = (.)func("glUniform2fv");
            glBindTextureUnit = (.)func("glBindTextureUnit");
            glUniform1dv = (.)func("glUniform1dv");
            glUniform3i = (.)func("glUniform3i");
            glGetIntegerv = (.)func("glGetIntegerv");
            glClearDepthf = (.)func("glClearDepthf");
            glClearBufferData = (.)func("glClearBufferData");
            glDisableVertexAttribArray = (.)func("glDisableVertexAttribArray");
            glGetProgramResourceiv = (.)func("glGetProgramResourceiv");
            glUniform4d = (.)func("glUniform4d");
            glClear = (.)func("glClear");
            glTextureBarrier = (.)func("glTextureBarrier");
            glCompressedTexSubImage3D = (.)func("glCompressedTexSubImage3D");
            glGetQueryIndexediv = (.)func("glGetQueryIndexediv");
            glVertexAttribP3uiv = (.)func("glVertexAttribP3uiv");
            glGetActiveSubroutineUniformName = (.)func("glGetActiveSubroutineUniformName");
            glGetTextureParameterIiv = (.)func("glGetTextureParameterIiv");
            glCopyBufferSubData = (.)func("glCopyBufferSubData");
            glReadBuffer = (.)func("glReadBuffer");
            glGetFramebufferAttachmentParameteriv = (.)func("glGetFramebufferAttachmentParameteriv");
            glUniform2iv = (.)func("glUniform2iv");
            glGetFragDataLocation = (.)func("glGetFragDataLocation");
            glProgramUniform2uiv = (.)func("glProgramUniform2uiv");
            glBindFragDataLocationIndexed = (.)func("glBindFragDataLocationIndexed");
            glDispatchComputeIndirect = (.)func("glDispatchComputeIndirect");
            glProgramUniform2f = (.)func("glProgramUniform2f");
            glGetQueryBufferObjecti64v = (.)func("glGetQueryBufferObjecti64v");
            glMultiTexCoordP4ui = (.)func("glMultiTexCoordP4ui");
            glGetTextureParameteriv = (.)func("glGetTextureParameteriv");
            glGetnMapdv = (.)func("glGetnMapdv");
            glReleaseShaderCompiler = (.)func("glReleaseShaderCompiler");
            glDrawTransformFeedbackInstanced = (.)func("glDrawTransformFeedbackInstanced");
            glGetnUniformdv = (.)func("glGetnUniformdv");
            glProgramUniform2i = (.)func("glProgramUniform2i");
            glGetTexParameterfv = (.)func("glGetTexParameterfv");
            glDrawArraysInstanced = (.)func("glDrawArraysInstanced");
            glGetTextureLevelParameterfv = (.)func("glGetTextureLevelParameterfv");
            glDeleteVertexArrays = (.)func("glDeleteVertexArrays");
            glGetUniformSubroutineuiv = (.)func("glGetUniformSubroutineuiv");
            glInvalidateTexImage = (.)func("glInvalidateTexImage");
            glGetVertexAttribIuiv = (.)func("glGetVertexAttribIuiv");
            glHint = (.)func("glHint");
            glProgramUniform2d = (.)func("glProgramUniform2d");
            glTexParameterfv = (.)func("glTexParameterfv");
            glGetBooleanv = (.)func("glGetBooleanv");
            glUniformBlockBinding = (.)func("glUniformBlockBinding");
            glDrawBuffer = (.)func("glDrawBuffer");
            glGetQueryObjectuiv = (.)func("glGetQueryObjectuiv");
            glGetTexLevelParameteriv = (.)func("glGetTexLevelParameteriv");
            glBindTextures = (.)func("glBindTextures");
            glEndQuery = (.)func("glEndQuery");
            glDeleteFramebuffers = (.)func("glDeleteFramebuffers");
            glUniform1fv = (.)func("glUniform1fv");
            glUniform1d = (.)func("glUniform1d");
            glTextureParameteri = (.)func("glTextureParameteri");
            glUniform1f = (.)func("glUniform1f");
            glCheckFramebufferStatus = (.)func("glCheckFramebufferStatus");
            glDisablei = (.)func("glDisablei");
            glBlitFramebuffer = (.)func("glBlitFramebuffer");
            glSamplerParameterIiv = (.)func("glSamplerParameterIiv");
            glTextureParameterf = (.)func("glTextureParameterf");
            glUniform1i = (.)func("glUniform1i");
            glGetShaderiv = (.)func("glGetShaderiv");
            glProgramUniform3f = (.)func("glProgramUniform3f");
            glUniformSubroutinesuiv = (.)func("glUniformSubroutinesuiv");
            glProgramUniform3i = (.)func("glProgramUniform3i");
            glBindBuffersBase = (.)func("glBindBuffersBase");
            glGetActiveUniformName = (.)func("glGetActiveUniformName");
            glBindFragDataLocation = (.)func("glBindFragDataLocation");
            glDrawElementsInstanced = (.)func("glDrawElementsInstanced");
            glGenRenderbuffers = (.)func("glGenRenderbuffers");
            glProgramUniform3d = (.)func("glProgramUniform3d");
            glGetActiveUniform = (.)func("glGetActiveUniform");
            glResumeTransformFeedback = (.)func("glResumeTransformFeedback");
            glCompileShader = (.)func("glCompileShader");
            glColorMask = (.)func("glColorMask");
            glMultiDrawElementsIndirect = (.)func("glMultiDrawElementsIndirect");
            glVertexAttribP3ui = (.)func("glVertexAttribP3ui");
            glVertexAttribI3iv = (.)func("glVertexAttribI3iv");
            glScissorIndexedv = (.)func("glScissorIndexedv");
            glGetnConvolutionFilter = (.)func("glGetnConvolutionFilter");
            glMultiTexCoordP3ui = (.)func("glMultiTexCoordP3ui");
            glUniformMatrix4x3dv = (.)func("glUniformMatrix4x3dv");
            glBindFramebuffer = (.)func("glBindFramebuffer");
            glGetCompressedTexImage = (.)func("glGetCompressedTexImage");
            glMultiTexCoordP2uiv = (.)func("glMultiTexCoordP2uiv");
            glDeleteQueries = (.)func("glDeleteQueries");
            glGetObjectPtrLabel = (.)func("glGetObjectPtrLabel");
            glUniform2uiv = (.)func("glUniform2uiv");
            glIsRenderbuffer = (.)func("glIsRenderbuffer");
            glVertexAttribI4i = (.)func("glVertexAttribI4i");
            glTextureStorage3DMultisample = (.)func("glTextureStorage3DMultisample");
            glVertexAttrib1fv = (.)func("glVertexAttrib1fv");
            glProgramUniform2ui = (.)func("glProgramUniform2ui");
            glTextureStorage2DMultisample = (.)func("glTextureStorage2DMultisample");
            glGetUniformiv = (.)func("glGetUniformiv");
            glMapNamedBuffer = (.)func("glMapNamedBuffer");
            glIsShader = (.)func("glIsShader");
            glBindVertexArray = (.)func("glBindVertexArray");
            glBlendFunci = (.)func("glBlendFunci");
            glBeginQuery = (.)func("glBeginQuery");
            glGetFloati_v = (.)func("glGetFloati_v");
            glGetProgramResourceName = (.)func("glGetProgramResourceName");
            glBindTexture = (.)func("glBindTexture");
            glUniform4fv = (.)func("glUniform4fv");
            glGetObjectLabel = (.)func("glGetObjectLabel");
            glUniform3dv = (.)func("glUniform3dv");
            glPolygonOffset = (.)func("glPolygonOffset");
            glGetShaderInfoLog = (.)func("glGetShaderInfoLog");
            glViewport = (.)func("glViewport");
            glVertexAttribI4usv = (.)func("glVertexAttribI4usv");
            glUniformMatrix4dv = (.)func("glUniformMatrix4dv");
            glIsEnabledi = (.)func("glIsEnabledi");
            glBindBuffersRange = (.)func("glBindBuffersRange");
            glGetDebugMessageLog = (.)func("glGetDebugMessageLog");
            glTexCoordP3uiv = (.)func("glTexCoordP3uiv");
            glGetInternalformati64v = (.)func("glGetInternalformati64v");
            glGetNamedBufferParameteriv = (.)func("glGetNamedBufferParameteriv");
            glVertexAttrib1dv = (.)func("glVertexAttrib1dv");
            glBindImageTexture = (.)func("glBindImageTexture");
            glShaderStorageBlockBinding = (.)func("glShaderStorageBlockBinding");
            glBeginConditionalRender = (.)func("glBeginConditionalRender");
            glFramebufferTexture = (.)func("glFramebufferTexture");
            glBlendEquation = (.)func("glBlendEquation");
            glUniform1uiv = (.)func("glUniform1uiv");
            glGenerateMipmap = (.)func("glGenerateMipmap");
            glMemoryBarrier = (.)func("glMemoryBarrier");
            glCreateBuffers = (.)func("glCreateBuffers");
            glVertexAttribDivisor = (.)func("glVertexAttribDivisor");
            glBeginQueryIndexed = (.)func("glBeginQueryIndexed");
            glDepthFunc = (.)func("glDepthFunc");
            glTexStorage2DMultisample = (.)func("glTexStorage2DMultisample");
            glUniform4iv = (.)func("glUniform4iv");
            glGetVertexArrayIndexediv = (.)func("glGetVertexArrayIndexediv");
            glGetnPolygonStipple = (.)func("glGetnPolygonStipple");
            glVertexAttribP4ui = (.)func("glVertexAttribP4ui");
            glCompressedTextureSubImage3D = (.)func("glCompressedTextureSubImage3D");
            glUniformMatrix4x3fv = (.)func("glUniformMatrix4x3fv");
            glVertexAttribI4iv = (.)func("glVertexAttribI4iv");
            glWaitSync = (.)func("glWaitSync");
            glMultiTexCoordP2ui = (.)func("glMultiTexCoordP2ui");
            glUniformMatrix4x2dv = (.)func("glUniformMatrix4x2dv");
            glClearColor = (.)func("glClearColor");
            glSamplerParameterIuiv = (.)func("glSamplerParameterIuiv");
            glCheckNamedFramebufferStatus = (.)func("glCheckNamedFramebufferStatus");
            glStencilFunc = (.)func("glStencilFunc");
            glProgramUniform3ui = (.)func("glProgramUniform3ui");
            glTextureBuffer = (.)func("glTextureBuffer");
            glVertexAttribI2i = (.)func("glVertexAttribI2i");
            glTexCoordP2uiv = (.)func("glTexCoordP2uiv");
            glVertexAttrib2fv = (.)func("glVertexAttrib2fv");
            glDeleteSync = (.)func("glDeleteSync");
            glVertexBindingDivisor = (.)func("glVertexBindingDivisor");
            glClearNamedFramebufferuiv = (.)func("glClearNamedFramebufferuiv");
            glVertexArrayAttribFormat = (.)func("glVertexArrayAttribFormat");
            glDepthMask = (.)func("glDepthMask");
            glVertexArrayAttribIFormat = (.)func("glVertexArrayAttribIFormat");
            glUniform3fv = (.)func("glUniform3fv");
            glUniform2dv = (.)func("glUniform2dv");
            glProgramUniform1uiv = (.)func("glProgramUniform1uiv");
            glGetnMapiv = (.)func("glGetnMapiv");
            glUseProgram = (.)func("glUseProgram");
            glGetProgramInterfaceiv = (.)func("glGetProgramInterfaceiv");
            glVertexArrayVertexBuffers = (.)func("glVertexArrayVertexBuffers");
            glGenTransformFeedbacks = (.)func("glGenTransformFeedbacks");
            glMultiTexCoordP1uiv = (.)func("glMultiTexCoordP1uiv");
            glUniformMatrix3dv = (.)func("glUniformMatrix3dv");
            glUniformMatrix4fv = (.)func("glUniformMatrix4fv");
            glColorP4ui = (.)func("glColorP4ui");
            glTextureView = (.)func("glTextureView");
            glVertexAttrib4uiv = (.)func("glVertexAttrib4uiv");
            glVertexAttribI3i = (.)func("glVertexAttribI3i");
            glStencilMask = (.)func("glStencilMask");
            glCopyTexImage1D = (.)func("glCopyTexImage1D");
            glVertexAttrib3fv = (.)func("glVertexAttrib3fv");
            glVertexAttrib2dv = (.)func("glVertexAttrib2dv");
            glGetUniformdv = (.)func("glGetUniformdv");
            glTexSubImage1D = (.)func("glTexSubImage1D");
            glBlendEquationSeparate = (.)func("glBlendEquationSeparate");
            glGetVertexAttribPointerv = (.)func("glGetVertexAttribPointerv");
            glVertexAttribL3dv = (.)func("glVertexAttribL3dv");
            glTransformFeedbackBufferRange = (.)func("glTransformFeedbackBufferRange");
            glCreateSamplers = (.)func("glCreateSamplers");
            glViewportIndexedf = (.)func("glViewportIndexedf");
            glVertexAttribI1iv = (.)func("glVertexAttribI1iv");
            glCompressedTextureSubImage1D = (.)func("glCompressedTextureSubImage1D");
            glUniformMatrix4x2fv = (.)func("glUniformMatrix4x2fv");
            glVertexAttribP1ui = (.)func("glVertexAttribP1ui");
            glDeleteSamplers = (.)func("glDeleteSamplers");
            glPauseTransformFeedback = (.)func("glPauseTransformFeedback");
            glNamedFramebufferRenderbuffer = (.)func("glNamedFramebufferRenderbuffer");
            glDisableVertexArrayAttrib = (.)func("glDisableVertexArrayAttrib");
            glGetUniformuiv = (.)func("glGetUniformuiv");
            glMultiDrawArrays = (.)func("glMultiDrawArrays");
            glTexCoordP4uiv = (.)func("glTexCoordP4uiv");
            glSecondaryColorP3uiv = (.)func("glSecondaryColorP3uiv");
            glTexStorage1D = (.)func("glTexStorage1D");
            glDrawArraysIndirect = (.)func("glDrawArraysIndirect");
            glProgramUniformMatrix3x4dv = (.)func("glProgramUniformMatrix3x4dv");
            glGetAttribLocation = (.)func("glGetAttribLocation");
            glMultiTexCoordP1ui = (.)func("glMultiTexCoordP1ui");
            glGetPointerv = (.)func("glGetPointerv");
            glCopyTexImage2D = (.)func("glCopyTexImage2D");
            glCreateShader = (.)func("glCreateShader");
            glCreateVertexArrays = (.)func("glCreateVertexArrays");
            glEndTransformFeedback = (.)func("glEndTransformFeedback");
            glSampleCoverage = (.)func("glSampleCoverage");
            glUniformMatrix2x3fv = (.)func("glUniformMatrix2x3fv");
            glProgramUniformMatrix4x2dv = (.)func("glProgramUniformMatrix4x2dv");
            glProgramUniformMatrix4x3fv = (.)func("glProgramUniformMatrix4x3fv");
            glGetBufferSubData = (.)func("glGetBufferSubData");
            glMultiDrawArraysIndirect = (.)func("glMultiDrawArraysIndirect");
            glCompressedTextureSubImage2D = (.)func("glCompressedTextureSubImage2D");
            glClearDepth = (.)func("glClearDepth");
            glDeleteTextures = (.)func("glDeleteTextures");
            glActiveShaderProgram = (.)func("glActiveShaderProgram");
            glVertexAttribLPointer = (.)func("glVertexAttribLPointer");
            glUniformMatrix3fv = (.)func("glUniformMatrix3fv");
            glTexSubImage2D = (.)func("glTexSubImage2D");
            glUniformMatrix2dv = (.)func("glUniformMatrix2dv");
            glNamedFramebufferDrawBuffers = (.)func("glNamedFramebufferDrawBuffers");
            glDeleteShader = (.)func("glDeleteShader");
            glUniform3uiv = (.)func("glUniform3uiv");
            glTexStorage2D = (.)func("glTexStorage2D");
            glVertexAttrib4iv = (.)func("glVertexAttrib4iv");
            glVertexAttribI1i = (.)func("glVertexAttribI1i");
            glGetUniformIndices = (.)func("glGetUniformIndices");
            glVertexAttrib4fv = (.)func("glVertexAttrib4fv");
            glGetnPixelMapusv = (.)func("glGetnPixelMapusv");
            glGetUniformfv = (.)func("glGetUniformfv");
            glVertexAttrib3dv = (.)func("glVertexAttrib3dv");
            glTextureParameteriv = (.)func("glTextureParameteriv");
            glIsTransformFeedback = (.)func("glIsTransformFeedback");
            glGetNamedBufferPointerv = (.)func("glGetNamedBufferPointerv");
            glDrawElementsBaseVertex = (.)func("glDrawElementsBaseVertex");
            glVertexAttribL4dv = (.)func("glVertexAttribL4dv");
            glProgramBinary = (.)func("glProgramBinary");
            glDrawArrays = (.)func("glDrawArrays");
            glVertexAttribI2iv = (.)func("glVertexAttribI2iv");
            glVertexAttribP2ui = (.)func("glVertexAttribP2ui");
            glGetSubroutineIndex = (.)func("glGetSubroutineIndex");
            glScissorIndexed = (.)func("glScissorIndexed");
            glGetNamedFramebufferParameteriv = (.)func("glGetNamedFramebufferParameteriv");
            glGetnPixelMapfv = (.)func("glGetnPixelMapfv");
            glTexSubImage3D = (.)func("glTexSubImage3D");
            glDrawRangeElements = (.)func("glDrawRangeElements");
            glCreateTextures = (.)func("glCreateTextures");
            glVertexAttribL4d = (.)func("glVertexAttribL4d");
            glDrawTransformFeedbackStreamInstanced = (.)func("glDrawTransformFeedbackStreamInstanced");
            glTexStorage3D = (.)func("glTexStorage3D");
            glProgramUniform1ui = (.)func("glProgramUniform1ui");
            glSamplerParameteri = (.)func("glSamplerParameteri");
            glGenQueries = (.)func("glGenQueries");
            glSamplerParameterf = (.)func("glSamplerParameterf");
            glVertexP2uiv = (.)func("glVertexP2uiv");
            glFlush = (.)func("glFlush");
            glGetActiveAttrib = (.)func("glGetActiveAttrib");
            glProgramUniformMatrix4x3dv = (.)func("glProgramUniformMatrix4x3dv");
            glGetActiveSubroutineUniformiv = (.)func("glGetActiveSubroutineUniformiv");
            glUniformMatrix2x4fv = (.)func("glUniformMatrix2x4fv");
            glUniformMatrix2x3dv = (.)func("glUniformMatrix2x3dv");
            glDrawTransformFeedbackStream = (.)func("glDrawTransformFeedbackStream");
            glUniform4dv = (.)func("glUniform4dv");
            glUniformMatrix2fv = (.)func("glUniformMatrix2fv");
            glDrawElementsIndirect = (.)func("glDrawElementsIndirect");
            glQueryCounter = (.)func("glQueryCounter");
            glEndQueryIndexed = (.)func("glEndQueryIndexed");
            glGetVertexAttribIiv = (.)func("glGetVertexAttribIiv");
            glGetQueryBufferObjectui64v = (.)func("glGetQueryBufferObjectui64v");
            glGetString = (.)func("glGetString");
            glGetTransformFeedbacki64_v = (.)func("glGetTransformFeedbacki64_v");
            glPointSize = (.)func("glPointSize");
            glUniformMatrix3x2fv = (.)func("glUniformMatrix3x2fv");
            glMultiDrawElementsBaseVertex = (.)func("glMultiDrawElementsBaseVertex");
            glShaderSource = (.)func("glShaderSource");
            glVertexAttrib4dv = (.)func("glVertexAttrib4dv");
            glFlushMappedNamedBufferRange = (.)func("glFlushMappedNamedBufferRange");
            glVertexAttribI4sv = (.)func("glVertexAttribI4sv");
            glClearNamedFramebufferfv = (.)func("glClearNamedFramebufferfv");
            glGetNamedRenderbufferParameteriv = (.)func("glGetNamedRenderbufferParameteriv");
            glInvalidateFramebuffer = (.)func("glInvalidateFramebuffer");
            glRenderbufferStorage = (.)func("glRenderbufferStorage");
            glTexCoordP4ui = (.)func("glTexCoordP4ui");
            glTextureStorage2D = (.)func("glTextureStorage2D");
            glGetTexImage = (.)func("glGetTexImage");
            glGetSubroutineUniformLocation = (.)func("glGetSubroutineUniformLocation");
            glProgramUniformMatrix2x4dv = (.)func("glProgramUniformMatrix2x4dv");
            glVertexAttribL1dv = (.)func("glVertexAttribL1dv");
            glBlendFuncSeparatei = (.)func("glBlendFuncSeparatei");
            glFramebufferTexture1D = (.)func("glFramebufferTexture1D");
            glGetActiveUniformBlockiv = (.)func("glGetActiveUniformBlockiv");
            glCreateProgramPipelines = (.)func("glCreateProgramPipelines");
            glTexImage2DMultisample = (.)func("glTexImage2DMultisample");
            glProgramUniformMatrix2fv = (.)func("glProgramUniformMatrix2fv");
            glTexImage3DMultisample = (.)func("glTexImage3DMultisample");
            glBlitNamedFramebuffer = (.)func("glBlitNamedFramebuffer");
            glVertexAttribL2d = (.)func("glVertexAttribL2d");
            glProgramUniformMatrix3x2dv = (.)func("glProgramUniformMatrix3x2dv");
            glGetBooleani_v = (.)func("glGetBooleani_v");
            glVertexAttrib4f = (.)func("glVertexAttrib4f");
            glGetQueryiv = (.)func("glGetQueryiv");
            glVertexAttrib4d = (.)func("glVertexAttrib4d");
            glTextureStorage1D = (.)func("glTextureStorage1D");
            glGetVertexAttribdv = (.)func("glGetVertexAttribdv");
            glTextureParameterIuiv = (.)func("glTextureParameterIuiv");
            glGetnColorTable = (.)func("glGetnColorTable");
            glGetInteger64v = (.)func("glGetInteger64v");
            glUniformMatrix2x4dv = (.)func("glUniformMatrix2x4dv");
            glTexParameterf = (.)func("glTexParameterf");
            glVertexAttrib4s = (.)func("glVertexAttrib4s");
            glVertexAttribI4ui = (.)func("glVertexAttribI4ui");
            glVertexAttrib4Nbv = (.)func("glVertexAttrib4Nbv");
            glVertexAttribL3d = (.)func("glVertexAttribL3d");
            glGetSynciv = (.)func("glGetSynciv");
            glGetnHistogram = (.)func("glGetnHistogram");
            glFlushMappedBufferRange = (.)func("glFlushMappedBufferRange");
            glUniformMatrix3x2dv = (.)func("glUniformMatrix3x2dv");
            glStencilOp = (.)func("glStencilOp");
            glIsBuffer = (.)func("glIsBuffer");
            glGetActiveAtomicCounterBufferiv = (.)func("glGetActiveAtomicCounterBufferiv");
            glVertexP3uiv = (.)func("glVertexP3uiv");
            glBindBuffer = (.)func("glBindBuffer");
            glVertexAttrib4bv = (.)func("glVertexAttrib4bv");
            glTexCoordP3ui = (.)func("glTexCoordP3ui");
            glTransformFeedbackVaryings = (.)func("glTransformFeedbackVaryings");
            glIsTexture = (.)func("glIsTexture");
            glVertexAttrib4usv = (.)func("glVertexAttrib4usv");
            glVertexAttribL2dv = (.)func("glVertexAttribL2dv");
            glFramebufferTexture3D = (.)func("glFramebufferTexture3D");
            glMultiTexCoordP4uiv = (.)func("glMultiTexCoordP4uiv");
            glBufferStorage = (.)func("glBufferStorage");
            glBlendColor = (.)func("glBlendColor");
            glMinSampleShading = (.)func("glMinSampleShading");
            glProgramUniformMatrix3fv = (.)func("glProgramUniformMatrix3fv");
            glProgramUniformMatrix2dv = (.)func("glProgramUniformMatrix2dv");
            glProgramUniformMatrix3x4fv = (.)func("glProgramUniformMatrix3x4fv");
            glTextureParameterfv = (.)func("glTextureParameterfv");
            glVertexArrayElementBuffer = (.)func("glVertexArrayElementBuffer");
            glValidateProgram = (.)func("glValidateProgram");
            glGetUniformBlockIndex = (.)func("glGetUniformBlockIndex");
            glInvalidateBufferData = (.)func("glInvalidateBufferData");
            glTextureStorage3D = (.)func("glTextureStorage3D");
            glGenBuffers = (.)func("glGenBuffers");
            glProgramUniformMatrix4x2fv = (.)func("glProgramUniformMatrix4x2fv");
            glTransformFeedbackBufferBase = (.)func("glTransformFeedbackBufferBase");
            glGetNamedBufferParameteri64v = (.)func("glGetNamedBufferParameteri64v");
            glMapNamedBufferRange = (.)func("glMapNamedBufferRange");
            glNamedFramebufferDrawBuffer = (.)func("glNamedFramebufferDrawBuffer");
            glVertexArrayAttribBinding = (.)func("glVertexArrayAttribBinding");
            glFramebufferParameteri = (.)func("glFramebufferParameteri");
            glClearNamedFramebufferfi = (.)func("glClearNamedFramebufferfi");
            glNamedRenderbufferStorageMultisample = (.)func("glNamedRenderbufferStorageMultisample");
            glFramebufferTexture2D = (.)func("glFramebufferTexture2D");
            glGetVertexAttribfv = (.)func("glGetVertexAttribfv");
            glViewportArrayv = (.)func("glViewportArrayv");
            glNamedFramebufferTextureLayer = (.)func("glNamedFramebufferTextureLayer");
            glEnable = (.)func("glEnable");
            glTexParameterIuiv = (.)func("glTexParameterIuiv");
            glVertexAttribL1d = (.)func("glVertexAttribL1d");
            glUniformMatrix3x4fv = (.)func("glUniformMatrix3x4fv");
            glProgramUniformMatrix2x3fv = (.)func("glProgramUniformMatrix2x3fv");
            glCompressedTexImage3D = (.)func("glCompressedTexImage3D");
            glDepthRange = (.)func("glDepthRange");
            glUnmapBuffer = (.)func("glUnmapBuffer");
            glTexCoordP2ui = (.)func("glTexCoordP2ui");
            glGetnPixelMapuiv = (.)func("glGetnPixelMapuiv");
            glTextureBufferRange = (.)func("glTextureBufferRange");
            glPointParameteri = (.)func("glPointParameteri");
            glPointParameterf = (.)func("glPointParameterf");
            glDepthRangeArrayv = (.)func("glDepthRangeArrayv");
            glGetFloatv = (.)func("glGetFloatv");
            glReadPixels = (.)func("glReadPixels");
            glCreateShaderProgramv = (.)func("glCreateShaderProgramv");
            glGetnTexImage = (.)func("glGetnTexImage");
            glProgramUniformMatrix3dv = (.)func("glProgramUniformMatrix3dv");
            glClearTexSubImage = (.)func("glClearTexSubImage");
            glProgramUniformMatrix4fv = (.)func("glProgramUniformMatrix4fv");
            glFramebufferTextureLayer = (.)func("glFramebufferTextureLayer");
            glGetTransformFeedbackVarying = (.)func("glGetTransformFeedbackVarying");
            glProgramUniform4dv = (.)func("glProgramUniform4dv");
            glGetVertexAttribLdv = (.)func("glGetVertexAttribLdv");
            glVertexP4uiv = (.)func("glVertexP4uiv");
            glUniformMatrix3x4dv = (.)func("glUniformMatrix3x4dv");
            glVertexAttrib4Nusv = (.)func("glVertexAttrib4Nusv");
            glProgramParameteri = (.)func("glProgramParameteri");
            glVertexAttribLFormat = (.)func("glVertexAttribLFormat");
            glUniform1ui = (.)func("glUniform1ui");
            glGetnCompressedTexImage = (.)func("glGetnCompressedTexImage");
            glVertexAttribI2ui = (.)func("glVertexAttribI2ui");
            glColorP3ui = (.)func("glColorP3ui");
            glPrimitiveRestartIndex = (.)func("glPrimitiveRestartIndex");
            glMapBuffer = (.)func("glMapBuffer");
            glMultiTexCoordP3uiv = (.)func("glMultiTexCoordP3uiv");
            glDrawElementsInstancedBaseInstance = (.)func("glDrawElementsInstancedBaseInstance");
            glClearBufferuiv = (.)func("glClearBufferuiv");
            glGetSamplerParameterIiv = (.)func("glGetSamplerParameterIiv");
            glGenerateTextureMipmap = (.)func("glGenerateTextureMipmap");
            glGetActiveSubroutineName = (.)func("glGetActiveSubroutineName");
            glMapBufferRange = (.)func("glMapBufferRange");
            glIsFramebuffer = (.)func("glIsFramebuffer");
            glProgramUniformMatrix4dv = (.)func("glProgramUniformMatrix4dv");
            glTexParameteri = (.)func("glTexParameteri");
            glFrontFace = (.)func("glFrontFace");
            glNamedFramebufferReadBuffer = (.)func("glNamedFramebufferReadBuffer");
            glTexCoordP1ui = (.)func("glTexCoordP1ui");
            glClipControl = (.)func("glClipControl");
            glCompressedTexImage1D = (.)func("glCompressedTexImage1D");
            glProgramUniformMatrix2x3dv = (.)func("glProgramUniformMatrix2x3dv");
            glDispatchCompute = (.)func("glDispatchCompute");
            glGetShaderSource = (.)func("glGetShaderSource");
            glProgramUniformMatrix2x4fv = (.)func("glProgramUniformMatrix2x4fv");
            glProgramUniformMatrix3x2fv = (.)func("glProgramUniformMatrix3x2fv");
            glBindBufferBase = (.)func("glBindBufferBase");
            glGetDoublev = (.)func("glGetDoublev");
            glGetVertexAttribiv = (.)func("glGetVertexAttribiv");
            glStencilOpSeparate = (.)func("glStencilOpSeparate");
            glVertexArrayAttribLFormat = (.)func("glVertexArrayAttribLFormat");
            glVertexAttrib4Niv = (.)func("glVertexAttrib4Niv");
            glClearNamedBufferSubData = (.)func("glClearNamedBufferSubData");
            glVertexArrayVertexBuffer = (.)func("glVertexArrayVertexBuffer");
            glClearNamedFramebufferiv = (.)func("glClearNamedFramebufferiv");
            glGetProgramBinary = (.)func("glGetProgramBinary");
            glCreateProgram = (.)func("glCreateProgram");
            glCompressedTexImage2D = (.)func("glCompressedTexImage2D");
            glGetQueryObjectiv = (.)func("glGetQueryObjectiv");
            glGetBufferPointerv = (.)func("glGetBufferPointerv");
            glDepthRangeIndexed = (.)func("glDepthRangeIndexed");
            glBindVertexBuffer = (.)func("glBindVertexBuffer");
            glVertexAttribI3ui = (.)func("glVertexAttribI3ui");
            glColorP4uiv = (.)func("glColorP4uiv");
            glVertexArrayBindingDivisor = (.)func("glVertexArrayBindingDivisor");
            glGetTexParameterIuiv = (.)func("glGetTexParameterIuiv");
            glVertexAttribBinding = (.)func("glVertexAttribBinding");
            glBindTransformFeedback = (.)func("glBindTransformFeedback");
            glGetCompressedTextureImage = (.)func("glGetCompressedTextureImage");
            glDeleteBuffers = (.)func("glDeleteBuffers");
            glSamplerParameterfv = (.)func("glSamplerParameterfv");
            glTexCoordP1uiv = (.)func("glTexCoordP1uiv");
            glSecondaryColorP3ui = (.)func("glSecondaryColorP3ui");
            glGetError = (.)func("glGetError");
            glGenProgramPipelines = (.)func("glGenProgramPipelines");
            glProgramUniform3fv = (.)func("glProgramUniform3fv");
            glProgramUniform2dv = (.)func("glProgramUniform2dv");
            glPatchParameteri = (.)func("glPatchParameteri");
            glCullFace = (.)func("glCullFace");
            glVertexAttribP1uiv = (.)func("glVertexAttribP1uiv");
            glGetGraphicsResetStatus = (.)func("glGetGraphicsResetStatus");
            glCopyTexSubImage3D = (.)func("glCopyTexSubImage3D");
            glNormalP3ui = (.)func("glNormalP3ui");
            glGetnSeparableFilter = (.)func("glGetnSeparableFilter");
            glTexParameterIiv = (.)func("glTexParameterIiv");
            glRenderbufferStorageMultisample = (.)func("glRenderbufferStorageMultisample");
            glObjectLabel = (.)func("glObjectLabel");
            glIsSampler = (.)func("glIsSampler");
            glBindBufferRange = (.)func("glBindBufferRange");
            glGetQueryObjecti64v = (.)func("glGetQueryObjecti64v");
            glSamplerParameteriv = (.)func("glSamplerParameteriv");
            glDrawElementsInstancedBaseVertexBaseInstance = (.)func("glDrawElementsInstancedBaseVertexBaseInstance");
            glDepthRangef = (.)func("glDepthRangef");
            glDisable = (.)func("glDisable");
            glLogicOp = (.)func("glLogicOp");
            glGetTransformFeedbackiv = (.)func("glGetTransformFeedbackiv");
            glUniform3ui = (.)func("glUniform3ui");
            glVertexAttribI4ubv = (.)func("glVertexAttribI4ubv");
            glProgramUniform4iv = (.)func("glProgramUniform4iv");
            glPixelStoref = (.)func("glPixelStoref");
            glCopyTextureSubImage3D = (.)func("glCopyTextureSubImage3D");
            glStencilFuncSeparate = (.)func("glStencilFuncSeparate");
            glPixelStorei = (.)func("glPixelStorei");
            glScissor = (.)func("glScissor");
            glGetAttachedShaders = (.)func("glGetAttachedShaders");
            glGetInteger64i_v = (.)func("glGetInteger64i_v");
            glGetProgramResourceLocationIndex = (.)func("glGetProgramResourceLocationIndex");
            glClearStencil = (.)func("glClearStencil");
            glProgramUniform1d = (.)func("glProgramUniform1d");
            glUnmapNamedBuffer = (.)func("glUnmapNamedBuffer");
            glProgramUniform1f = (.)func("glProgramUniform1f");
            glProgramUniform1i = (.)func("glProgramUniform1i");
            glGetTextureLevelParameteriv = (.)func("glGetTextureLevelParameteriv");
            glGetActiveUniformsiv = (.)func("glGetActiveUniformsiv");
            glNamedFramebufferTexture = (.)func("glNamedFramebufferTexture");
            glNamedBufferSubData = (.)func("glNamedBufferSubData");
            glTexParameteriv = (.)func("glTexParameteriv");
            glShaderBinary = (.)func("glShaderBinary");
            glGetTextureImage = (.)func("glGetTextureImage");
            glProgramUniform4fv = (.)func("glProgramUniform4fv");
            glTexImage2D = (.)func("glTexImage2D");
            glCopyTexSubImage1D = (.)func("glCopyTexSubImage1D");
            glUniform4f = (.)func("glUniform4f");
            glCopyTextureSubImage2D = (.)func("glCopyTextureSubImage2D");
            glUniform4i = (.)func("glUniform4i");
            glBindSamplers = (.)func("glBindSamplers");
            glTexStorage3DMultisample = (.)func("glTexStorage3DMultisample");
            glGetBufferParameteri64v = (.)func("glGetBufferParameteri64v");
            glGetFragDataIndex = (.)func("glGetFragDataIndex");
            glColorP3uiv = (.)func("glColorP3uiv");
            glClientWaitSync = (.)func("glClientWaitSync");
            glDebugMessageInsert = (.)func("glDebugMessageInsert");
            glProgramUniform3dv = (.)func("glProgramUniform3dv");
            glMultiDrawElements = (.)func("glMultiDrawElements");
            glViewportIndexedfv = (.)func("glViewportIndexedfv");
            glValidateProgramPipeline = (.)func("glValidateProgramPipeline");
            glTexImage3D = (.)func("glTexImage3D");
            glGetProgramPipelineiv = (.)func("glGetProgramPipelineiv");
            glCopyTexSubImage2D = (.)func("glCopyTexSubImage2D");
            glBlendEquationSeparatei = (.)func("glBlendEquationSeparatei");
            glGetNamedBufferSubData = (.)func("glGetNamedBufferSubData");
            glDeleteRenderbuffers = (.)func("glDeleteRenderbuffers");
            glCreateRenderbuffers = (.)func("glCreateRenderbuffers");
            glVertexAttribI1ui = (.)func("glVertexAttribI1ui");
            glCopyTextureSubImage1D = (.)func("glCopyTextureSubImage1D");
            glEnablei = (.)func("glEnablei");
            glVertexAttribI1uiv = (.)func("glVertexAttribI1uiv");
            glUniform2ui = (.)func("glUniform2ui");
            glGetSamplerParameterIuiv = (.)func("glGetSamplerParameterIuiv");
            glVertexAttrib4Nuiv = (.)func("glVertexAttrib4Nuiv");
            glReadnPixels = (.)func("glReadnPixels");
            glBlendEquationi = (.)func("glBlendEquationi");
            glGetProgramiv = (.)func("glGetProgramiv");
            glIsProgramPipeline = (.)func("glIsProgramPipeline");
            glColorMaski = (.)func("glColorMaski");
            glGetRenderbufferParameteriv = (.)func("glGetRenderbufferParameteriv");
            glVertexAttrib1d = (.)func("glVertexAttrib1d");
            glNamedBufferStorage = (.)func("glNamedBufferStorage");
            glProgramUniform1fv = (.)func("glProgramUniform1fv");
            glBlendFuncSeparate = (.)func("glBlendFuncSeparate");
            glProgramUniform4uiv = (.)func("glProgramUniform4uiv");
            glGenTextures = (.)func("glGenTextures");
            glVertexAttrib1f = (.)func("glVertexAttrib1f");
            glGetShaderPrecisionFormat = (.)func("glGetShaderPrecisionFormat");
            glBufferData = (.)func("glBufferData");
            glVertexAttrib1s = (.)func("glVertexAttrib1s");
            glEndConditionalRender = (.)func("glEndConditionalRender");
            glDetachShader = (.)func("glDetachShader");
            glTexBuffer = (.)func("glTexBuffer");
            glGetnUniformuiv = (.)func("glGetnUniformuiv");
            glAttachShader = (.)func("glAttachShader");
            glGetIntegeri_v = (.)func("glGetIntegeri_v");
            glPopDebugGroup = (.)func("glPopDebugGroup");
            glGetProgramStageiv = (.)func("glGetProgramStageiv");
            glPatchParameterfv = (.)func("glPatchParameterfv");
            glProgramUniform2iv = (.)func("glProgramUniform2iv");
            glTexImage1D = (.)func("glTexImage1D");
            glGenSamplers = (.)func("glGenSamplers");
            glMemoryBarrierByRegion = (.)func("glMemoryBarrierByRegion");
            glGetBufferParameteriv = (.)func("glGetBufferParameteriv");
            glTextureSubImage3D = (.)func("glTextureSubImage3D");
            glDrawBuffers = (.)func("glDrawBuffers");
            glVertexAttribI3uiv = (.)func("glVertexAttribI3uiv");
            glClearTexImage = (.)func("glClearTexImage");
            glInvalidateBufferSubData = (.)func("glInvalidateBufferSubData");
            glVertexAttrib1sv = (.)func("glVertexAttrib1sv");
            glVertexP4ui = (.)func("glVertexP4ui");
            glGetProgramInfoLog = (.)func("glGetProgramInfoLog");
            glGetProgramResourceLocation = (.)func("glGetProgramResourceLocation");
            glDebugMessageCallback = (.)func("glDebugMessageCallback");
            glGetnUniformiv = (.)func("glGetnUniformiv");
            glGetQueryObjectui64v = (.)func("glGetQueryObjectui64v");
            glNamedRenderbufferStorage = (.)func("glNamedRenderbufferStorage");
            glProgramUniform1dv = (.)func("glProgramUniform1dv");
            glVertexAttrib3f = (.)func("glVertexAttrib3f");
            glGetVertexArrayIndexed64iv = (.)func("glGetVertexArrayIndexed64iv");
            glStencilMaskSeparate = (.)func("glStencilMaskSeparate");
            glVertexAttrib3d = (.)func("glVertexAttrib3d");
            glProgramUniform2fv = (.)func("glProgramUniform2fv");
            glTextureSubImage2D = (.)func("glTextureSubImage2D");
            glDebugMessageControl = (.)func("glDebugMessageControl");
            glGetFramebufferParameteriv = (.)func("glGetFramebufferParameteriv");
            glVertexAttribI2uiv = (.)func("glVertexAttribI2uiv");
            glDeleteProgramPipelines = (.)func("glDeleteProgramPipelines");
            glGetActiveUniformBlockName = (.)func("glGetActiveUniformBlockName");
            glGetDoublei_v = (.)func("glGetDoublei_v");
            glVertexAttrib3s = (.)func("glVertexAttrib3s");
            glVertexAttrib2f = (.)func("glVertexAttrib2f");
            glVertexAttribIPointer = (.)func("glVertexAttribIPointer");
            glDrawTransformFeedback = (.)func("glDrawTransformFeedback");
            glUniform4ui = (.)func("glUniform4ui");
            glVertexAttrib2d = (.)func("glVertexAttrib2d");
            glDrawRangeElementsBaseVertex = (.)func("glDrawRangeElementsBaseVertex");
            glProgramUniform3iv = (.)func("glProgramUniform3iv");
            glCopyImageSubData = (.)func("glCopyImageSubData");
            glIsProgram = (.)func("glIsProgram");
            glBeginTransformFeedback = (.)func("glBeginTransformFeedback");
            glObjectPtrLabel = (.)func("glObjectPtrLabel");
            glGetQueryBufferObjectuiv = (.)func("glGetQueryBufferObjectuiv");
            glTexBufferRange = (.)func("glTexBufferRange");
            glInvalidateTexSubImage = (.)func("glInvalidateTexSubImage");
            glIsSync = (.)func("glIsSync");
            glTextureSubImage1D = (.)func("glTextureSubImage1D");
            glFinish = (.)func("glFinish");
            glGetProgramPipelineInfoLog = (.)func("glGetProgramPipelineInfoLog");
            glVertexAttrib2sv = (.)func("glVertexAttrib2sv");
            glVertexAttrib2s = (.)func("glVertexAttrib2s");
            glFramebufferRenderbuffer = (.)func("glFramebufferRenderbuffer");
            glGetTexParameterIiv = (.)func("glGetTexParameterIiv");
            glActiveTexture = (.)func("glActiveTexture");
            glVertexAttribFormat = (.)func("glVertexAttribFormat");
            glDrawArraysInstancedBaseInstance = (.)func("glDrawArraysInstancedBaseInstance");
            glLinkProgram = (.)func("glLinkProgram");
        }
    }
}
