/**************************************************************************
*
* Copyright 2013-2014 RAD Game Tools and Valve Software
* Copyright 2010-2014 Rich Geldreich and Tenacious Software LLC
* All Rights Reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*
* Ported at 08f2c2d
*
**************************************************************************/

using System;
using System.Diagnostics;

namespace Pile
{
	static class MiniZ
	{
		typealias size_t = int;

		// miniz.h

		typealias mz_ulong = uint;

#if BF_LITTLE_ENDIAN
	#define MINIZ_LITTLE_ENDIAN		
#endif

#if BF_64_BIT
	#define MINIZ_HAS_64BIT_REGISTERS
#endif

#define MINIZ_USE_UNALIGNED_LOADS_AND_STORES
//#define MINIZ_UNALIGNED_USE_MEMCPY

		public enum CompressionStrategy
		{
		    DEFAULT_STRATEGY = 0,
		    FILTERED = 1,
		    HUFFMAN_ONLY = 2,
		    RLE = 3,
		    FIXED = 4
		};

		const int32 DEFLATED = 8;

		public function void* mz_alloc_func(void* opaque, int items, int size);
		public function void mz_free_func(void* opaque, void* address);
		//public function void* ReallocFunc(void* opaque, void* address, int items, int size); // ???

		/* Compression levels: 0-9 are the standard zlib-style levels, 10 is best possible compression (not zlib compatible, and may be very slow), MZ_DEFAULT_COMPRESSION=MZ_DEFAULT_LEVEL. */
		public enum CompressionLevel
		{
		    NO_COMPRESSION = 0,
		    BEST_SPEED = 1,
		    BEST_COMPRESSION = 9,
		    UBER_COMPRESSION = 10,
		    DEFAULT_LEVEL = 6,
		    DEFAULT_COMPRESSION = -1
		};

		public const String VERSION = "10.1.0";
		public const int32 VERNUM = 0xA100;
		public const int32 VER_MAJOR = 10;
		public const int32 VER_MINOR = 1;
		public const int32 VER_REVISION = 0;
		public const int32 VER_SUBREVISION = 0;

		/* Flush values. For typical usage you only need MZ_NO_FLUSH and MZ_FINISH. The other values are for advanced use (refer to the zlib docs). */
		public enum FlushValue
		{
		    NO_FLUSH = 0,
		    PARTIAL_FLUSH = 1,
		    SYNC_FLUSH = 2,
		    FULL_FLUSH = 3,
		    FINISH = 4,
		    BLOCK = 5
		};

		/* Return status codes. MZ_PARAM_ERROR is non-standard. */
		public enum ReturnStatus
		{
		    OK = 0,
		    STREAM_END = 1,
		    NEED_DICT = 2,
		    ERRNO = -1,
		    STREAM_ERROR = -2,
		    DATA_ERROR = -3,
		    MEM_ERROR = -4,
		    BUF_ERROR = -5,
		    VERSION_ERROR = -6,
		    PARAM_ERROR = -10000
		};

		public const int32 DEFAULT_WINDOW_BITS = 15;

		/* Compression/decompression stream struct. */
		public struct mz_stream // mz_stream_s
		{
		    public uint8* next_in; /* pointer to next byte to read */
		    public uint32 avail_in;        /* number of bytes available at next_in */
		    public mz_ulong total_in;            /* total number of bytes consumed so far */

		    public uint8* next_out; /* pointer to next byte to write */
		    public uint32 avail_out;  /* number of bytes that can be written to next_out */
		    public mz_ulong total_out;      /* total number of bytes produced so far */

		    public char8* msg;                       /* error msg (unused) */
		    public void* state; /* internal state, allocated by zalloc/zfree */

		    public mz_alloc_func zalloc; /* optional heap allocation function (defaults to malloc) */
		    public mz_free_func zfree;   /* optional heap free function (defaults to free) */
		    public void *opaque;         /* heap alloc function user pointer */

		    public int32 data_type;     /* data_type (unused) */
		    public mz_ulong adler;    /* adler32 of the source or uncompressed data */
		    public mz_ulong reserved; /* not used */
		};

		// miniz_common.h

		typealias mz_uint8 = uint8;
		typealias mz_int16 = int16;
		typealias mz_uint16 = uint16;
		typealias mz_uint32 = uint32;
		typealias mz_uint = uint32;
		typealias mz_int64  = int64;
		typealias mz_uint64 = uint64;
		/*typealias mz_bool = int32;*/

		/*const int32 MZ_TRUE = 1;
		const int32 MZ_FALSE = 0;*/
		
		typealias MZ_TIME_T /* = time_t*/ = uint64;

		[CLink, CallingConvention(.Stdcall)]
		static extern void* malloc(int size);
		[CLink, CallingConvention(.Stdcall)]
		static extern void free(void* ptr);
		[CLink, CallingConvention(.Stdcall)]
		static extern void* realloc(void* ptr, int newSize);

		[Inline]
		static void* MZ_MALLOC(int size) => malloc(size);
		[Inline]
		static void MZ_FREE(void* ptr) => free(ptr);
		[Inline]
		static void* MZ_REALLOC(void* ptr, int newSize) => realloc(ptr, newSize);

		[Inline]
		static void memcpy(void* dest, void* src, int len) => Internal.MemCpy(dest, src, len);
		[Inline]
		static void memset(void* addr, uint8 val, int len) => Internal.MemSet(addr, val, len);

		static mixin MZ_MAX(var a, var b) { (((a) > (b)) ? (a) : (b)) }
		static mixin MZ_MIN(var a, var b) { (((a) < (b)) ? (a) : (b)) }

#if MINIZ_USE_UNALIGNED_LOADS_AND_STORES && MINIZ_LITTLE_ENDIAN
		[Inline]
		static mz_uint16 MZ_READ_LE16(void* ptr) => *((mz_uint16*)ptr);
		[Inline]
		static mz_uint32 MZ_READ_LE32(void* ptr) => *((mz_uint32*)ptr);
#else
		[Inline]
		static mz_uint16 MZ_READ_LE16(void* p) => ((mz_uint16)(((mz_uint8*)p)[0]) | (mz_uint16)(((mz_uint8*)p)[1]) << 8U);
		[Inline]
		static mz_uint32 MZ_READ_LE32(void* p) => ((mz_uint32)(((mz_uint8*)p)[0]) | ((mz_uint32)(((mz_uint8*)p)[1]) << 8U) | ((mz_uint32)(((mz_uint8*)p)[2]) << 16U) | ((mz_uint32)(((mz_uint8*)p)[3]) << 24U));
#endif
		[Inline]
		static mz_uint64 MZ_READ_LE64(void* p) => (((mz_uint64)MZ_READ_LE32(p)) | (((mz_uint64)MZ_READ_LE32(((mz_uint8*)(p)) + sizeof(mz_uint32))) << 32U));

		static void* miniz_def_alloc_func(void *opaque, size_t items, size_t size)
		{
			return MZ_MALLOC(items * size);
		}
		static void miniz_def_free_func(void *opaque, void *address)
		{
			MZ_FREE(address);
		}
		static void* miniz_def_realloc_func(void *opaque, void *address, size_t items, size_t size)
		{
			return MZ_REALLOC(address, items * size);
		}

		const uint MZ_UINT16_MAX = (0xFFFFU);
		const uint MZ_UINT32_MAX = (0xFFFFFFFFU);

		// miniz_tdef.h

		/* tdefl_init() compression flags logically OR'd together (low 12 bits contain the max. number of probes per dictionary search): */
		/* TDEFL_DEFAULT_MAX_PROBES: The compressor defaults to 128 dictionary probes per dictionary search. 0=Huffman only, 1=Huffman+LZ (fastest/crap compression), 4095=Huffman+LZ (slowest/best compression). */
		
		/* TDEFL_WRITE_ZLIB_HEADER: If set, the compressor outputs a zlib header before the deflate data, and the Adler-32 of the source data at the end. Otherwise, you'll get raw deflate data. */
		/* TDEFL_COMPUTE_ADLER32: Always compute the adler-32 of the input data (even when not writing zlib headers). */
		/* TDEFL_GREEDY_PARSING_FLAG: Set to use faster greedy parsing, instead of more efficient lazy parsing. */
		/* TDEFL_NONDETERMINISTIC_PARSING_FLAG: Enable to decrease the compressor's initialization time to the minimum, but the output may vary from run to run given the same input (depending on the contents of memory). */
		/* TDEFL_RLE_MATCHES: Only look for RLE matches (matches with a distance of 1) */
		/* TDEFL_FILTER_MATCHES: Discards matches <= 5 chars if enabled. */
		/* TDEFL_FORCE_ALL_STATIC_BLOCKS: Disable usage of optimized Huffman tables. */
		/* TDEFL_FORCE_ALL_RAW_BLOCKS: Only use raw (uncompressed) deflate blocks. */
		/* The low 12 bits are reserved to control the max # of hash probes per dictionary lookup (see TDEFL_MAX_PROBES_MASK). */
		public enum tdefl_flags : mz_uint
		{
		    TDEFL_HUFFMAN_ONLY = 0,
		    TDEFL_DEFAULT_MAX_PROBES = 128,
		    TDEFL_MAX_PROBES_MASK = 0xFFF,

			TDEFL_WRITE_ZLIB_HEADER = 0x01000,
			TDEFL_COMPUTE_ADLER32 = 0x02000,
			TDEFL_GREEDY_PARSING_FLAG = 0x04000,
			TDEFL_NONDETERMINISTIC_PARSING_FLAG = 0x08000,
			TDEFL_RLE_MATCHES = 0x10000,
			TDEFL_FILTER_MATCHES = 0x20000,
			TDEFL_FORCE_ALL_STATIC_BLOCKS = 0x40000,
			TDEFL_FORCE_ALL_RAW_BLOCKS = 0x80000
		};

		public static function bool tdefl_put_buf_func_ptr(void* pBuf, int len, void* pUser);

		const int32 TDEFL_MAX_HUFF_TABLES = 3;
		const int32 TDEFL_MAX_HUFF_SYMBOLS_0 = 288;
		const int32 TDEFL_MAX_HUFF_SYMBOLS_1 = 32;
		const int32 TDEFL_MAX_HUFF_SYMBOLS_2 = 19;
		const int32 TDEFL_LZ_DICT_SIZE = 32768;
		const int32 TDEFL_LZ_DICT_SIZE_MASK = TDEFL_LZ_DICT_SIZE - 1;
		const int32 TDEFL_MIN_MATCH_LEN = 3;
		const int32 TDEFL_MAX_MATCH_LEN = 258;

#if TDEFL_LESS_MEMORY
		const int32 TDEFL_LZ_CODE_BUF_SIZE = 24 * 1024;
		const int32 TDEFL_OUT_BUF_SIZE = (TDEFL_LZ_CODE_BUF_SIZE * 13) / 10;
		const int32 TDEFL_MAX_HUFF_SYMBOLS = 288;
		const int32 TDEFL_LZ_HASH_BITS = 12;
		const int32 TDEFL_LEVEL1_HASH_SIZE_MASK = 4095;
		const int32 TDEFL_LZ_HASH_SHIFT = (TDEFL_LZ_HASH_BITS + 2) / 3;
		const int32 TDEFL_LZ_HASH_SIZE = 1 << TDEFL_LZ_HASH_BITS;
#else
		const int32 TDEFL_LZ_CODE_BUF_SIZE = 64 * 1024;
		const int32 TDEFL_OUT_BUF_SIZE = (TDEFL_LZ_CODE_BUF_SIZE * 13) / 10;
		const int32 TDEFL_MAX_HUFF_SYMBOLS = 288;
		const int32 TDEFL_LZ_HASH_BITS = 15;
		const int32 TDEFL_LEVEL1_HASH_SIZE_MASK = 4095;
		const int32 TDEFL_LZ_HASH_SHIFT = (TDEFL_LZ_HASH_BITS + 2) / 3;
		const int32 TDEFL_LZ_HASH_SIZE = 1 << TDEFL_LZ_HASH_BITS;
#endif

		/* The low-level tdefl functions below may be used directly if the above helper functions aren't flexible enough. The low-level functions don't make any heap allocations, unlike the above helper functions. */
		public enum tdefl_status {
		    TDEFL_STATUS_BAD_PARAM = -2,
		    TDEFL_STATUS_PUT_BUF_FAILED = -1,
		    TDEFL_STATUS_OKAY = 0,
		    TDEFL_STATUS_DONE = 1
		};

		/* Must map to MZ_NO_FLUSH, MZ_SYNC_FLUSH, etc. enums */
		public enum tdefl_flush {
		    TDEFL_NO_FLUSH = 0,
		    TDEFL_SYNC_FLUSH = 2,
		    TDEFL_FULL_FLUSH = 3,
		    TDEFL_FINISH = 4
		};

		/* tdefl's compression state structure. */
		public struct tdefl_compressor
		{
		    public tdefl_put_buf_func_ptr m_pPut_buf_func;
		    public void* m_pPut_buf_user;
			public tdefl_flags m_flags;
		    public mz_uint[2] m_max_probes;
		    public int m_greedy_parsing;
		    public mz_uint m_adler32, m_lookahead_pos, m_lookahead_size, m_dict_size;
		    public mz_uint8* m_pLZ_code_buf, m_pLZ_flags, m_pOutput_buf, m_pOutput_buf_end;
		    public mz_uint m_num_flags_left, m_total_lz_bytes, m_lz_code_buf_dict_pos, m_bits_in, m_bit_buffer;
		    public mz_uint m_saved_match_dist, m_saved_match_len, m_saved_lit, m_output_flush_ofs, m_output_flush_remaining, m_block_index;
			public bool m_finished, m_wants_to_finish; // @change
		    public tdefl_status m_prev_return_status;
		    public void* m_pIn_buf;
		    public void* m_pOut_buf;
		    public size_t* m_pIn_buf_size, m_pOut_buf_size;
		    public tdefl_flush m_flush;
		    public mz_uint8* m_pSrc;
		    public size_t m_src_buf_left, m_out_buf_ofs;
		    public mz_uint8[TDEFL_LZ_DICT_SIZE + TDEFL_MAX_MATCH_LEN - 1] m_dict;
		    public mz_uint16[TDEFL_MAX_HUFF_TABLES][TDEFL_MAX_HUFF_SYMBOLS] m_huff_count;
		    public mz_uint16[TDEFL_MAX_HUFF_TABLES][TDEFL_MAX_HUFF_SYMBOLS] m_huff_codes;
		    public mz_uint8[TDEFL_MAX_HUFF_TABLES][TDEFL_MAX_HUFF_SYMBOLS] m_huff_code_sizes;
		    public mz_uint8[TDEFL_LZ_CODE_BUF_SIZE] m_lz_code_buf;
		    public mz_uint16[TDEFL_LZ_DICT_SIZE] m_next;
		    public mz_uint16[TDEFL_LZ_HASH_SIZE] m_hash;
		    public mz_uint8[TDEFL_OUT_BUF_SIZE] m_output_buf;
		};

		// miniz_tinf.h

		/* Decompression flags used by tinfl_decompress(). */
		/* TINFL_FLAG_PARSE_ZLIB_HEADER: If set, the input has a valid zlib header and ends with an adler32 checksum (it's a valid zlib stream). Otherwise, the input is a raw deflate stream. */
		/* TINFL_FLAG_HAS_MORE_INPUT: If set, there are more input bytes available beyond the end of the supplied input buffer. If clear, the input buffer contains all remaining input. */
		/* TINFL_FLAG_USING_NON_WRAPPING_OUTPUT_BUF: If set, the output buffer is large enough to hold the entire decompressed stream. If clear, the output buffer is at least the size of the dictionary (typically 32KB). */
		/* TINFL_FLAG_COMPUTE_ADLER32: Force adler-32 checksum computation of the decompressed bytes. */
		public enum tinfl_flags
		{
		    TINFL_FLAG_PARSE_ZLIB_HEADER = 1,
		    TINFL_FLAG_HAS_MORE_INPUT = 2,
		    TINFL_FLAG_USING_NON_WRAPPING_OUTPUT_BUF = 4,
		    TINFL_FLAG_COMPUTE_ADLER32 = 8
		};

		const size_t TINFL_DECOMPRESS_MEM_TO_MEM_FAILED = ((size_t)(-1));

		public function bool tinfl_put_buf_func_ptr(void *pBuf, int32 len, void *pUser);

		typealias  tinfl_decompressor = tinfl_decompressor_tag;

		const int32 TINFL_LZ_DICT_SIZE = 32768;

		/* Return status. */
		public enum tinfl_status {
		    /* This flags indicates the inflator needs 1 or more input bytes to make forward progress, but the caller is indicating that no more are available. The compressed data */
		    /* is probably corrupted. If you call the inflator again with more bytes it'll try to continue processing the input but this is a BAD sign (either the data is corrupted or you called it incorrectly). */
		    /* If you call it again with no input you'll just get TINFL_STATUS_FAILED_CANNOT_MAKE_PROGRESS again. */
		    TINFL_STATUS_FAILED_CANNOT_MAKE_PROGRESS = -4,

		    /* This flag indicates that one or more of the input parameters was obviously bogus. (You can try calling it again, but if you get this error the calling code is wrong.) */
		    TINFL_STATUS_BAD_PARAM = -3,

		    /* This flags indicate the inflator is finished but the adler32 check of the uncompressed data didn't match. If you call it again it'll return TINFL_STATUS_DONE. */
		    TINFL_STATUS_ADLER32_MISMATCH = -2,

		    /* This flags indicate the inflator has somehow failed (bad code, corrupted input, etc.). If you call it again without resetting via tinfl_init() it it'll just keep on returning the same status failure code. */
		    TINFL_STATUS_FAILED = -1,

		    /* Any status code less than TINFL_STATUS_DONE must indicate a failure. */

		    /* This flag indicates the inflator has returned every byte of uncompressed data that it can, has consumed every byte that it needed, has successfully reached the end of the deflate stream, and */
		    /* if zlib headers and adler32 checking enabled that it has successfully checked the uncompressed data's adler32. If you call it again you'll just get TINFL_STATUS_DONE over and over again. */
		    TINFL_STATUS_DONE = 0,

		    /* This flag indicates the inflator MUST have more input data (even 1 byte) before it can make any more forward progress, or you need to clear the TINFL_FLAG_HAS_MORE_INPUT */
		    /* flag on the next call if you don't have any more source data. If the source data was somehow corrupted it's also possible (but unlikely) for the inflator to keep on demanding input to */
		    /* proceed, so be sure to properly set the TINFL_FLAG_HAS_MORE_INPUT flag. */
		    TINFL_STATUS_NEEDS_MORE_INPUT = 1,

		    /* This flag indicates the inflator definitely has 1 or more bytes of uncompressed data available, but it cannot write this data into the output buffer. */
		    /* Note if the source compressed data was corrupted it's possible for the inflator to return a lot of uncompressed data to the caller. I've been assuming you know how much uncompressed data to expect */
		    /* (either exact or worst case) and will stop calling the inflator and fail after receiving too much. In pure streaming scenarios where you have no idea how many bytes to expect this may not be possible */
		    /* so I may need to add some code to address this. */
		    TINFL_STATUS_HAS_MORE_OUTPUT = 2
		};

		/* Initializes the decompressor to its initial state. */
		static mixin tinfl_init(var r)
		{
			(r).m_state = 0;
		}
		static mixin tinfl_get_adler32(var r)
		{
			(r).m_check_adler32
		}

		/* Internal/private bits follow. */
		const int32 TINFL_MAX_HUFF_TABLES = 3;
		const int32 TINFL_MAX_HUFF_SYMBOLS_0 = 288;
		const int32 TINFL_MAX_HUFF_SYMBOLS_1 = 32;
		const int32 TINFL_MAX_HUFF_SYMBOLS_2 = 19;
		const int32 TINFL_FAST_LOOKUP_BITS = 10;
		const int32 TINFL_FAST_LOOKUP_SIZE = 1 << TINFL_FAST_LOOKUP_BITS;

		struct tinfl_huff_table
		{
		    public mz_uint8[TINFL_MAX_HUFF_SYMBOLS_0] m_code_size;
		    public mz_int16[TINFL_FAST_LOOKUP_SIZE] m_look_up;
			public mz_int16[TINFL_MAX_HUFF_SYMBOLS_0 * 2] m_tree;
		};

#if MINIZ_HAS_64BIT_REGISTERS
	#define TINFL_USE_64BIT_BITBUF
#endif

		
#if TINFL_USE_64BIT_BITBUF
		typealias tinfl_bit_buf_t = mz_uint64;
		const int32 TINFL_BITBUF_SIZE = (64);
#else
		typealias tinfl_bit_buf_t = mz_uint32;
		const int32 TINFL_BITBUF_SIZE = (32);
#endif

		struct tinfl_decompressor_tag
		{
		    public mz_uint32 m_state, m_num_bits, m_zhdr0, m_zhdr1, m_z_adler32, m_final, m_type, m_check_adler32, m_dist, m_counter, m_num_extra;
			public mz_uint32[TINFL_MAX_HUFF_TABLES] m_table_sizes;
		    public tinfl_bit_buf_t m_bit_buf;
		    public size_t m_dist_from_out_buf_start;
		    public tinfl_huff_table[TINFL_MAX_HUFF_TABLES] m_tables;
		    public mz_uint8[4] m_raw_header;
			public mz_uint8[TINFL_MAX_HUFF_SYMBOLS_0 + TINFL_MAX_HUFF_SYMBOLS_1 + 137] m_len_codes;
		};

		// miniz.c

		/* ------------------- zlib-style API's */

		const mz_ulong MZ_ADLER32_INIT = 1;
		static mz_ulong mz_adler32(mz_ulong adler, uint8 *ptr, size_t buf_len)
		{
			var ptr;
			var buf_len;
		    mz_uint32 i, s1 = (mz_uint32)(adler & 0xffff), s2 = (mz_uint32)(adler >> 16);
		    size_t block_len = buf_len % 5552;
		    if (ptr == null)
		        return MZ_ADLER32_INIT;
		    while (buf_len != 0)
		    {
		        for (i = 0; i + 7 < block_len; i += 8, ptr += 8)
		        {
		            s1 += ptr[0]; s2 += s1;
		            s1 += ptr[1]; s2 += s1;
		            s1 += ptr[2]; s2 += s1;
		            s1 += ptr[3]; s2 += s1;
		            s1 += ptr[4]; s2 += s1;
		            s1 += ptr[5]; s2 += s1;
		            s1 += ptr[6]; s2 += s1;
		            s1 += ptr[7]; s2 += s1;
		        }
		        for (; i < block_len; ++i)
				{
		            s1 += *ptr++; s2 += s1;
				}
		        s1 %= 65521U; s2 %= 65521U;
		        buf_len -= block_len;
		        block_len = 5552;
		    }
		    return (s2 << 16) + s1;
		}
		
		const mz_ulong MZ_CRC32_INIT = 0;
		/* Faster, but larger CPU cache footprint.
		 */
		static mz_ulong mz_crc32(mz_ulong crc, mz_uint8 *ptr, size_t buf_len)
		{
			var buf_len;
		    const mz_uint32[256] s_crc_table =
		        .(
		          0x00000000, 0x77073096, 0xEE0E612C, 0x990951BA, 0x076DC419, 0x706AF48F, 0xE963A535,
		          0x9E6495A3, 0x0EDB8832, 0x79DCB8A4, 0xE0D5E91E, 0x97D2D988, 0x09B64C2B, 0x7EB17CBD,
		          0xE7B82D07, 0x90BF1D91, 0x1DB71064, 0x6AB020F2, 0xF3B97148, 0x84BE41DE, 0x1ADAD47D,
		          0x6DDDE4EB, 0xF4D4B551, 0x83D385C7, 0x136C9856, 0x646BA8C0, 0xFD62F97A, 0x8A65C9EC,
		          0x14015C4F, 0x63066CD9, 0xFA0F3D63, 0x8D080DF5, 0x3B6E20C8, 0x4C69105E, 0xD56041E4,
		          0xA2677172, 0x3C03E4D1, 0x4B04D447, 0xD20D85FD, 0xA50AB56B, 0x35B5A8FA, 0x42B2986C,
		          0xDBBBC9D6, 0xACBCF940, 0x32D86CE3, 0x45DF5C75, 0xDCD60DCF, 0xABD13D59, 0x26D930AC,
		          0x51DE003A, 0xC8D75180, 0xBFD06116, 0x21B4F4B5, 0x56B3C423, 0xCFBA9599, 0xB8BDA50F,
		          0x2802B89E, 0x5F058808, 0xC60CD9B2, 0xB10BE924, 0x2F6F7C87, 0x58684C11, 0xC1611DAB,
		          0xB6662D3D, 0x76DC4190, 0x01DB7106, 0x98D220BC, 0xEFD5102A, 0x71B18589, 0x06B6B51F,
		          0x9FBFE4A5, 0xE8B8D433, 0x7807C9A2, 0x0F00F934, 0x9609A88E, 0xE10E9818, 0x7F6A0DBB,
		          0x086D3D2D, 0x91646C97, 0xE6635C01, 0x6B6B51F4, 0x1C6C6162, 0x856530D8, 0xF262004E,
		          0x6C0695ED, 0x1B01A57B, 0x8208F4C1, 0xF50FC457, 0x65B0D9C6, 0x12B7E950, 0x8BBEB8EA,
		          0xFCB9887C, 0x62DD1DDF, 0x15DA2D49, 0x8CD37CF3, 0xFBD44C65, 0x4DB26158, 0x3AB551CE,
		          0xA3BC0074, 0xD4BB30E2, 0x4ADFA541, 0x3DD895D7, 0xA4D1C46D, 0xD3D6F4FB, 0x4369E96A,
		          0x346ED9FC, 0xAD678846, 0xDA60B8D0, 0x44042D73, 0x33031DE5, 0xAA0A4C5F, 0xDD0D7CC9,
		          0x5005713C, 0x270241AA, 0xBE0B1010, 0xC90C2086, 0x5768B525, 0x206F85B3, 0xB966D409,
		          0xCE61E49F, 0x5EDEF90E, 0x29D9C998, 0xB0D09822, 0xC7D7A8B4, 0x59B33D17, 0x2EB40D81,
		          0xB7BD5C3B, 0xC0BA6CAD, 0xEDB88320, 0x9ABFB3B6, 0x03B6E20C, 0x74B1D29A, 0xEAD54739,
		          0x9DD277AF, 0x04DB2615, 0x73DC1683, 0xE3630B12, 0x94643B84, 0x0D6D6A3E, 0x7A6A5AA8,
		          0xE40ECF0B, 0x9309FF9D, 0x0A00AE27, 0x7D079EB1, 0xF00F9344, 0x8708A3D2, 0x1E01F268,
		          0x6906C2FE, 0xF762575D, 0x806567CB, 0x196C3671, 0x6E6B06E7, 0xFED41B76, 0x89D32BE0,
		          0x10DA7A5A, 0x67DD4ACC, 0xF9B9DF6F, 0x8EBEEFF9, 0x17B7BE43, 0x60B08ED5, 0xD6D6A3E8,
		          0xA1D1937E, 0x38D8C2C4, 0x4FDFF252, 0xD1BB67F1, 0xA6BC5767, 0x3FB506DD, 0x48B2364B,
		          0xD80D2BDA, 0xAF0A1B4C, 0x36034AF6, 0x41047A60, 0xDF60EFC3, 0xA867DF55, 0x316E8EEF,
		          0x4669BE79, 0xCB61B38C, 0xBC66831A, 0x256FD2A0, 0x5268E236, 0xCC0C7795, 0xBB0B4703,
		          0x220216B9, 0x5505262F, 0xC5BA3BBE, 0xB2BD0B28, 0x2BB45A92, 0x5CB36A04, 0xC2D7FFA7,
		          0xB5D0CF31, 0x2CD99E8B, 0x5BDEAE1D, 0x9B64C2B0, 0xEC63F226, 0x756AA39C, 0x026D930A,
		          0x9C0906A9, 0xEB0E363F, 0x72076785, 0x05005713, 0x95BF4A82, 0xE2B87A14, 0x7BB12BAE,
		          0x0CB61B38, 0x92D28E9B, 0xE5D5BE0D, 0x7CDCEFB7, 0x0BDBDF21, 0x86D3D2D4, 0xF1D4E242,
		          0x68DDB3F8, 0x1FDA836E, 0x81BE16CD, 0xF6B9265B, 0x6FB077E1, 0x18B74777, 0x88085AE6,
		          0xFF0F6A70, 0x66063BCA, 0x11010B5C, 0x8F659EFF, 0xF862AE69, 0x616BFFD3, 0x166CCF45,
		          0xA00AE278, 0xD70DD2EE, 0x4E048354, 0x3903B3C2, 0xA7672661, 0xD06016F7, 0x4969474D,
		          0x3E6E77DB, 0xAED16A4A, 0xD9D65ADC, 0x40DF0B66, 0x37D83BF0, 0xA9BCAE53, 0xDEBB9EC5,
		          0x47B2CF7F, 0x30B5FFE9, 0xBDBDF21C, 0xCABAC28A, 0x53B39330, 0x24B4A3A6, 0xBAD03605,
		          0xCDD70693, 0x54DE5729, 0x23D967BF, 0xB3667A2E, 0xC4614AB8, 0x5D681B02, 0x2A6F2B94,
		          0xB40BBE37, 0xC30C8EA1, 0x5A05DF1B, 0x2D02EF8D
		        );

		    mz_uint32 crc32 = (mz_uint32)crc ^ 0xFFFFFFFF;
		    mz_uint8 *pByte_buf = (mz_uint8 *)ptr;

		    while (buf_len >= 4)
		    {
		        crc32 = (crc32 >> 8) ^ s_crc_table[(crc32 ^ pByte_buf[0]) & 0xFF];
		        crc32 = (crc32 >> 8) ^ s_crc_table[(crc32 ^ pByte_buf[1]) & 0xFF];
		        crc32 = (crc32 >> 8) ^ s_crc_table[(crc32 ^ pByte_buf[2]) & 0xFF];
		        crc32 = (crc32 >> 8) ^ s_crc_table[(crc32 ^ pByte_buf[3]) & 0xFF];
		        pByte_buf += 4;
		        buf_len -= 4;
		    }

		    while (buf_len != 0)
		    {
		        crc32 = (crc32 >> 8) ^ s_crc_table[(crc32 ^ pByte_buf[0]) & 0xFF];
		        ++pByte_buf;
		        --buf_len;
		    }

		    return ~crc32;
		}


		public static String mz_version()
		{
		    return VERSION;
		}

#if !MINIZ_NO_ZLIB_APIS

		public static ReturnStatus mz_deflateInit(mz_stream* pStream, CompressionLevel level)
		{
		    return mz_deflateInit(pStream, level, DEFLATED, DEFAULT_WINDOW_BITS, 9, .DEFAULT_STRATEGY);
		}

		public static ReturnStatus mz_deflateInit(mz_stream* pStream, CompressionLevel level, int32 method, int32 window_bits, int32 mem_level, CompressionStrategy strategy)
		{
		    tdefl_compressor *pComp;
		    tdefl_flags comp_flags = .TDEFL_COMPUTE_ADLER32 | tdefl_create_comp_flags_from_zip_params(level, window_bits, strategy);

		    if (pStream == null)
		        return .STREAM_ERROR;
		    if ((method != DEFLATED) || ((mem_level < 1) || (mem_level > 9)) || ((window_bits != DEFAULT_WINDOW_BITS) && (-window_bits != DEFAULT_WINDOW_BITS)))
		        return .PARAM_ERROR;

		    pStream.data_type = 0;
		    pStream.adler = MZ_ADLER32_INIT;
		    pStream.msg = null;
		    pStream.reserved = 0;
		    pStream.total_in = 0;
		    pStream.total_out = 0;
		    if (pStream.zalloc == null)
		        pStream.zalloc = => miniz_def_alloc_func;
		    if (pStream.zfree == null)
		        pStream.zfree = => miniz_def_free_func;

		    pComp = (tdefl_compressor*)pStream.zalloc(pStream.opaque, 1, sizeof(tdefl_compressor));
		    if (pComp == null)
		        return .MEM_ERROR;

		    pStream.state = (void*)pComp;

		    if (tdefl_init(pComp, null, null, comp_flags) != .TDEFL_STATUS_OKAY)
		    {
		        mz_deflateEnd(pStream);
		        return .PARAM_ERROR;
		    }

		    return .OK;
		}

		public static ReturnStatus mz_deflateReset(mz_stream* pStream)
		{
		    if ((pStream == null) || (pStream.state == null) || (pStream.zalloc == null) || (pStream.zfree == null))
		        return .STREAM_ERROR;
		    pStream.total_in = pStream.total_out = 0;
		    tdefl_init((tdefl_compressor *)pStream.state, null, null, ((tdefl_compressor *)pStream.state).m_flags);
		    return .OK;
		}

		public static ReturnStatus mz_deflate(mz_stream* pStream, FlushValue flush)
		{
			var flush;
		    size_t in_bytes, out_bytes;
		    mz_ulong orig_total_in, orig_total_out;
		    ReturnStatus mz_status = .OK;

		    if ((pStream == null) || (pStream.state == null) || (flush < 0) || (flush > .FINISH) || (pStream.next_out == null))
		        return .STREAM_ERROR;
		    if (pStream.avail_out == 0)
		        return .BUF_ERROR;

		    if (flush == .PARTIAL_FLUSH)
		        flush = .SYNC_FLUSH;

		    if (((tdefl_compressor *)pStream.state).m_prev_return_status == .TDEFL_STATUS_DONE)
		        return (flush == .FINISH) ? .STREAM_END : .BUF_ERROR;

		    orig_total_in = pStream.total_in;
		    orig_total_out = pStream.total_out;
		    for (;;)
		    {
		        tdefl_status defl_status;
		        in_bytes = pStream.avail_in;
		        out_bytes = pStream.avail_out;

		        defl_status = tdefl_compress((tdefl_compressor *)pStream.state, pStream.next_in, &in_bytes, pStream.next_out, &out_bytes, (tdefl_flush)flush);
		        pStream.next_in += (mz_uint)in_bytes;
		        pStream.avail_in -= (mz_uint)in_bytes;
		        pStream.total_in += (mz_uint)in_bytes;
		        pStream.adler = tdefl_get_adler32((tdefl_compressor *)pStream.state);

		        pStream.next_out += (mz_uint)out_bytes;
		        pStream.avail_out -= (mz_uint)out_bytes;
		        pStream.total_out += (mz_uint)out_bytes;

		        if (defl_status < 0)
		        {
		            mz_status = .STREAM_ERROR;
		            break;
		        }
		        else if (defl_status == .TDEFL_STATUS_DONE)
		        {
		            mz_status = .STREAM_END;
		            break;
		        }
		        else if (pStream.avail_out == 0)
		            break;
		        else if ((pStream.avail_in == 0) && (flush != .FINISH))
		        {
		            if ((flush != 0) || (pStream.total_in != orig_total_in) || (pStream.total_out != orig_total_out))
		                break;
		            return .BUF_ERROR; /* Can't make forward progress without some input. */
		        }
		    }
		    return mz_status;
		}

		public static ReturnStatus mz_deflateEnd(mz_stream* pStream)
		{
		    if (pStream == null)
		        return .STREAM_ERROR;
		    if (pStream.state != null)
		    {
		        pStream.zfree(pStream.opaque, pStream.state);
		        pStream.state = null;
		    }
		    return .OK;
		}

		public static mz_ulong mz_deflateBound(mz_stream* pStream, mz_ulong source_len)
		{
		    //(void)pStream;
		    /* This is really over conservative. (And lame, but it's actually pretty tricky to compute a true upper bound given the way tdefl's blocking works.) */
		    return MZ_MAX!(128 + (source_len * 110) / 100, 128 + source_len + ((source_len / (31 * 1024)) + 1) * 5);
		}

		public static ReturnStatus mz_compress(uint8* pDest, mz_ulong *pDest_len, uint8* pSource, mz_ulong source_len, CompressionLevel level)
		{
		    ReturnStatus status;
		    mz_stream stream = default;

		    /* In case mz_ulong is 64-bits (argh I hate longs). */
		    if ((source_len | *pDest_len) > 0xFFFFFFFFU)
		        return .PARAM_ERROR;

		    stream.next_in = pSource;
		    stream.avail_in = (mz_uint32)source_len;
		    stream.next_out = pDest;
		    stream.avail_out = (mz_uint32)*pDest_len;

		    status = mz_deflateInit(&stream, level);
		    if (status != .OK)
		        return status;

		    status = mz_deflate(&stream, .FINISH);
		    if (status != .STREAM_END)
		    {
		        mz_deflateEnd(&stream);
		        return (status == .OK) ? .BUF_ERROR : status;
		    }

		    *pDest_len = stream.total_out;
		    return mz_deflateEnd(&stream);
		}

		public static ReturnStatus mz_compress(uint8* pDest, mz_ulong *pDest_len, uint8* pSource, mz_ulong source_len)
		{
		    return mz_compress(pDest, pDest_len, pSource, source_len, .DEFAULT_COMPRESSION);
		}

		public static mz_ulong mz_compressBound(mz_ulong source_len)
		{
		    return mz_deflateBound(null, source_len);
		}

		struct inflate_state
		{
		    public tinfl_decompressor m_decomp;
		    public mz_uint m_dict_ofs, m_dict_avail;
			public bool m_first_call, m_has_flushed;
		    public int32 m_window_bits;
		    public mz_uint8[TINFL_LZ_DICT_SIZE] m_dict;
		    public tinfl_status m_last_status;
		};

		public static ReturnStatus mz_inflateInit(mz_stream* pStream, int32 window_bits)
		{
		    inflate_state *pDecomp;
		    if (pStream == null)
		        return .STREAM_ERROR;
		    if ((window_bits != DEFAULT_WINDOW_BITS) && (-window_bits != DEFAULT_WINDOW_BITS))
		        return .PARAM_ERROR;

		    pStream.data_type = 0;
		    pStream.adler = 0;
		    pStream.msg = null;
		    pStream.total_in = 0;
		    pStream.total_out = 0;
		    pStream.reserved = 0;
		    if (pStream.zalloc == null)
		        pStream.zalloc = => miniz_def_alloc_func;
		    if (pStream.zfree == null)
		        pStream.zfree = => miniz_def_free_func;

		    pDecomp = (inflate_state *)pStream.zalloc(pStream.opaque, 1, sizeof(inflate_state));
		    if (pDecomp == null)
		        return .MEM_ERROR;

		    pStream.state = (void*)pDecomp;

		    tinfl_init!(&pDecomp.m_decomp);
		    pDecomp.m_dict_ofs = 0;
		    pDecomp.m_dict_avail = 0;
		    pDecomp.m_last_status = .TINFL_STATUS_NEEDS_MORE_INPUT;
		    pDecomp.m_first_call = true;
		    pDecomp.m_has_flushed = false;
		    pDecomp.m_window_bits = window_bits;

		    return .OK;
		}

		public static ReturnStatus mz_inflateInit(mz_stream* pStream)
		{
		    return mz_inflateInit(pStream, DEFAULT_WINDOW_BITS);
		}

		public static ReturnStatus mz_inflateReset(mz_stream* pStream)
		{
		    inflate_state *pDecomp;
		    if (pStream == null)
		        return .STREAM_ERROR;

		    pStream.data_type = 0;
		    pStream.adler = 0;
		    pStream.msg = null;
		    pStream.total_in = 0;
		    pStream.total_out = 0;
		    pStream.reserved = 0;

		    pDecomp = (inflate_state *)pStream.state;

		    tinfl_init!(&pDecomp.m_decomp);
		    pDecomp.m_dict_ofs = 0;
		    pDecomp.m_dict_avail = 0;
		    pDecomp.m_last_status = .TINFL_STATUS_NEEDS_MORE_INPUT;
		    pDecomp.m_first_call = true;
		    pDecomp.m_has_flushed = false;
		    /* pDecomp.m_window_bits = window_bits; */

		    return .OK;
		}

		public static ReturnStatus mz_inflate(mz_stream* pStream, FlushValue flush)
		{
			var flush;
		    inflate_state* pState;
		    mz_uint n;
			bool first_call;
			tinfl_flags decomp_flags = .TINFL_FLAG_COMPUTE_ADLER32;
		    size_t in_bytes, out_bytes, orig_avail_in;
		    tinfl_status status = default;

		    if ((pStream == null) || (pStream.state == null))
		        return .STREAM_ERROR;
		    if (flush == .PARTIAL_FLUSH)
		        flush = .SYNC_FLUSH;
		    if ((flush != 0) && (flush != .SYNC_FLUSH) && (flush != .FINISH))
		        return .STREAM_ERROR;

		    pState = (inflate_state *)pStream.state;
		    if (pState.m_window_bits > 0)
		        decomp_flags |= .TINFL_FLAG_PARSE_ZLIB_HEADER;
		    orig_avail_in = pStream.avail_in;

		    first_call = pState.m_first_call;
		    pState.m_first_call = false;
		    if (pState.m_last_status < 0)
		        return .DATA_ERROR;

		    if (pState.m_has_flushed && (flush != .FINISH))
		        return .STREAM_ERROR;
		    pState.m_has_flushed |= (flush == .FINISH);

		    if ((flush == .FINISH) && (first_call))
		    {
		        /* MZ_FINISH on the first call implies that the input and output buffers are large enough to hold the entire compressed/decompressed file. */
		        decomp_flags |= .TINFL_FLAG_USING_NON_WRAPPING_OUTPUT_BUF;
		        in_bytes = pStream.avail_in;
		        out_bytes = pStream.avail_out;
		        status = tinfl_decompress(&pState.m_decomp, pStream.next_in, &in_bytes, pStream.next_out, pStream.next_out, &out_bytes, decomp_flags);
		        pState.m_last_status = status;
		        pStream.next_in += (mz_uint)in_bytes;
		        pStream.avail_in -= (mz_uint)in_bytes;
		        pStream.total_in += (mz_uint)in_bytes;
		        pStream.adler = tinfl_get_adler32!(&pState.m_decomp);
		        pStream.next_out += (mz_uint)out_bytes;
		        pStream.avail_out -= (mz_uint)out_bytes;
		        pStream.total_out += (mz_uint)out_bytes;

		        if (status < 0)
		            return .DATA_ERROR;
		        else if (status != .TINFL_STATUS_DONE)
		        {
		            pState.m_last_status = .TINFL_STATUS_FAILED;
		            return .BUF_ERROR;
		        }
		        return .STREAM_END;
		    }
		    /* flush != MZ_FINISH then we must assume there's more input. */
		    if (flush != .FINISH)
		        decomp_flags |= .TINFL_FLAG_HAS_MORE_INPUT;

		    if (pState.m_dict_avail != 0)
		    {
		        n = MZ_MIN!(pState.m_dict_avail, pStream.avail_out);
		        memcpy(pStream.next_out, &pState.m_dict[pState.m_dict_ofs], n);
		        pStream.next_out += n;
		        pStream.avail_out -= n;
		        pStream.total_out += n;
		        pState.m_dict_avail -= n;
		        pState.m_dict_ofs = (pState.m_dict_ofs + n) & (TINFL_LZ_DICT_SIZE - 1);
		        return ((pState.m_last_status == .TINFL_STATUS_DONE) && (pState.m_dict_avail == 0)) ? .STREAM_END : .OK;
		    }

		    for (;;)
		    {
		        in_bytes = pStream.avail_in;
		        out_bytes = TINFL_LZ_DICT_SIZE - pState.m_dict_ofs;

		        status = tinfl_decompress(&pState.m_decomp, pStream.next_in, &in_bytes, &pState.m_dict[0], &pState.m_dict[pState.m_dict_ofs], &out_bytes, decomp_flags);
		        pState.m_last_status = status;

		        pStream.next_in += (mz_uint)in_bytes;
		        pStream.avail_in -= (mz_uint)in_bytes;
		        pStream.total_in += (mz_uint)in_bytes;
		        pStream.adler = tinfl_get_adler32!(&pState.m_decomp);

		        pState.m_dict_avail = (mz_uint)out_bytes;

		        n = MZ_MIN!(pState.m_dict_avail, pStream.avail_out);
		        memcpy(pStream.next_out, &pState.m_dict[pState.m_dict_ofs], n);
		        pStream.next_out += n;
		        pStream.avail_out -= n;
		        pStream.total_out += n;
		        pState.m_dict_avail -= n;
		        pState.m_dict_ofs = (pState.m_dict_ofs + n) & (TINFL_LZ_DICT_SIZE - 1);

		        if (status < 0)
		            return .DATA_ERROR; /* Stream is corrupted (there could be some uncompressed data left in the output dictionary - oh well). */
		        else if ((status == .TINFL_STATUS_NEEDS_MORE_INPUT) && (orig_avail_in == 0))
		            return .BUF_ERROR; /* Signal caller that we can't make forward progress without supplying more input or by setting flush to MZ_FINISH. */
		        else if (flush == .FINISH)
		        {
		            /* The output buffer MUST be large to hold the remaining uncompressed data when flush==MZ_FINISH. */
		            if (status == .TINFL_STATUS_DONE)
		                return pState.m_dict_avail != 0 ? .BUF_ERROR : .STREAM_END;
		            /* status here must be TINFL_STATUS_HAS_MORE_OUTPUT, which means there's at least 1 more byte on the way. If there's no more room left in the output buffer then something is wrong. */
		            else if (pStream.avail_out == 0)
		                return .BUF_ERROR;
		        }
		        else if ((status == .TINFL_STATUS_DONE) || (pStream.avail_in == 0) || (pStream.avail_out == 0) || (pState.m_dict_avail != 0))
		            break;
		    }

		    return ((status == .TINFL_STATUS_DONE) && (pState.m_dict_avail == 0)) ? .STREAM_END : .OK;
		}

		public static ReturnStatus mz_inflateEnd(mz_stream* pStream)
		{
		    if (pStream == null)
		        return .STREAM_ERROR;
		    if (pStream.state != null)
		    {
		        pStream.zfree(pStream.opaque, pStream.state);
		        pStream.state = null;
		    }
		    return .OK;
		}
		public static ReturnStatus mz_uncompress(uint8* pDest, mz_ulong *pDest_len, uint8* pSource, mz_ulong *pSource_len)
		{
		    mz_stream stream = default;
		    ReturnStatus status;

		    /* In case mz_ulong is 64-bits (argh I hate longs). */
		    if ((*pSource_len | *pDest_len) > 0xFFFFFFFFU)
		        return .PARAM_ERROR;

		    stream.next_in = pSource;
		    stream.avail_in = (mz_uint32)*pSource_len;
		    stream.next_out = pDest;
		    stream.avail_out = (mz_uint32)*pDest_len;

		    status = mz_inflateInit(&stream);
		    if (status != .OK)
		        return status;

		    status = mz_inflate(&stream, .FINISH);
		    *pSource_len = *pSource_len - stream.avail_in;
		    if (status != .STREAM_END)
		    {
		        mz_inflateEnd(&stream);
		        return ((status == .BUF_ERROR) && (stream.avail_in == 0)) ? .DATA_ERROR : status;
		    }
		    *pDest_len = stream.total_out;

		    return mz_inflateEnd(&stream);
		}

		public static ReturnStatus mz_uncompress(uint8* pDest, mz_ulong *pDest_len, uint8* pSource, mz_ulong source_len)
		{
			var source_len;
		    return mz_uncompress(pDest, pDest_len, pSource, &source_len);
		}

		struct error_desc : this(ReturnStatus m_err, String m_pDesc);

		static error_desc[?] s_error_descs = .(
			.(.OK, ""),
			.(.STREAM_END, "stream end"),
			.(.NEED_DICT, "need dictionary"),
			.(.ERRNO, "file error"),
			.(.STREAM_ERROR, "stream error"),
			.(.DATA_ERROR, "data error"),
			.(.MEM_ERROR, "out of memory"),
			.(.BUF_ERROR, "buf error"),
			.(.VERSION_ERROR, "version error"),
			.(.PARAM_ERROR, "parameter error")
			);

		public static String mz_error(ReturnStatus err)
		{
		    mz_uint i;
		    for (i = 0; i < s_error_descs.Count; ++i)
		        if (s_error_descs[i].m_err == err)
		            return s_error_descs[i].m_pDesc;
		    return null;
		}

#endif /*MINIZ_NO_ZLIB_APIS */

		// miniz_tdef.c

		/* ------------------- Low-level Compression (independent from all decompression API's) */

		/* Purposely making these tables static for faster init and thread safety. */
		static mz_uint16[256] s_tdefl_len_sym =
		    .(
		      257, 258, 259, 260, 261, 262, 263, 264, 265, 265, 266, 266, 267, 267, 268, 268, 269, 269, 269, 269, 270, 270, 270, 270, 271, 271, 271, 271, 272, 272, 272, 272,
		      273, 273, 273, 273, 273, 273, 273, 273, 274, 274, 274, 274, 274, 274, 274, 274, 275, 275, 275, 275, 275, 275, 275, 275, 276, 276, 276, 276, 276, 276, 276, 276,
		      277, 277, 277, 277, 277, 277, 277, 277, 277, 277, 277, 277, 277, 277, 277, 277, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278,
		      279, 279, 279, 279, 279, 279, 279, 279, 279, 279, 279, 279, 279, 279, 279, 279, 280, 280, 280, 280, 280, 280, 280, 280, 280, 280, 280, 280, 280, 280, 280, 280,
		      281, 281, 281, 281, 281, 281, 281, 281, 281, 281, 281, 281, 281, 281, 281, 281, 281, 281, 281, 281, 281, 281, 281, 281, 281, 281, 281, 281, 281, 281, 281, 281,
		      282, 282, 282, 282, 282, 282, 282, 282, 282, 282, 282, 282, 282, 282, 282, 282, 282, 282, 282, 282, 282, 282, 282, 282, 282, 282, 282, 282, 282, 282, 282, 282,
		      283, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283,
		      284, 284, 284, 284, 284, 284, 284, 284, 284, 284, 284, 284, 284, 284, 284, 284, 284, 284, 284, 284, 284, 284, 284, 284, 284, 284, 284, 284, 284, 284, 284, 285
		    );

		static mz_uint8[256] s_tdefl_len_extra =
		    .(
		      0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
		      4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
		      5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
		      5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 0
		    );

		static mz_uint8[512] s_tdefl_small_dist_sym =
		    .(
		      0, 1, 2, 3, 4, 4, 5, 5, 6, 6, 6, 6, 7, 7, 7, 7, 8, 8, 8, 8, 8, 8, 8, 8, 9, 9, 9, 9, 9, 9, 9, 9, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 11, 11, 11, 11, 11, 11,
		      11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 13,
		      13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14,
		      14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14,
		      14, 14, 14, 14, 14, 14, 14, 14, 14, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15,
		      15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16,
		      16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16,
		      16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16,
		      16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17,
		      17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17,
		      17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17,
		      17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17
		    );

		static mz_uint8[512] s_tdefl_small_dist_extra =
		    .(
		      0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 5, 5, 5,
		      5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,
		      6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,
		      6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
		      7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
		      7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
		      7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
		      7, 7, 7, 7, 7, 7, 7, 7
		    );

		static mz_uint8[128] s_tdefl_large_dist_sym =
		    .(
		      0, 0, 18, 19, 20, 20, 21, 21, 22, 22, 22, 22, 23, 23, 23, 23, 24, 24, 24, 24, 24, 24, 24, 24, 25, 25, 25, 25, 25, 25, 25, 25, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26,
		      26, 26, 26, 26, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28,
		      28, 28, 28, 28, 28, 28, 28, 28, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29
		    );

		static mz_uint8[128] s_tdefl_large_dist_extra =
		    .(
		      0, 0, 8, 8, 9, 9, 9, 9, 10, 10, 10, 10, 10, 10, 10, 10, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12,
		      12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13,
		      13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13
		    );

		/* Radix sorts tdefl_sym_freq[] array by 16-bit key m_key. Returns ptr to sorted values. */
		struct tdefl_sym_freq
		{
		    public mz_uint16 m_key, m_sym_index;
		};

		static tdefl_sym_freq *tdefl_radix_sort_syms(mz_uint num_syms, tdefl_sym_freq *pSyms0, tdefl_sym_freq *pSyms1)
		{
		    mz_uint32 total_passes = 2, pass_shift, pass, i;
			mz_uint32[256 * 2] hist = .();
		    tdefl_sym_freq* pCur_syms = pSyms0, pNew_syms = pSyms1;
		    for (i = 0; i < num_syms; i++)
		    {
		        mz_uint freq = pSyms0[i].m_key;
		        hist[freq & 0xFF]++;
		        hist[256 + ((freq >> 8) & 0xFF)]++;
		    }
		    while ((total_passes > 1) && (num_syms == hist[(total_passes - 1) * 256]))
		        total_passes--;
		    for (pass_shift = 0, pass = 0; pass < total_passes; pass++, pass_shift += 8)
		    {
		        mz_uint32 *pHist = &hist[pass << 8];
		        mz_uint[256] offsets = ?;
				mz_uint cur_ofs = 0;
		        for (i = 0; i < 256; i++)
		        {
		            offsets[i] = cur_ofs;
		            cur_ofs += pHist[i];
		        }
		        for (i = 0; i < num_syms; i++)
		            pNew_syms[offsets[(pCur_syms[i].m_key >> pass_shift) & 0xFF]++] = pCur_syms[i];
		        {
		            tdefl_sym_freq *t = pCur_syms;
		            pCur_syms = pNew_syms;
		            pNew_syms = t;
		        }
		    }
		    return pCur_syms;
		}

		/* tdefl_calculate_minimum_redundancy() originally written by: Alistair Moffat, alistair@cs.mu.oz.au, Jyrki Katajainen, jyrki@diku.dk, November 1996. */
		static void tdefl_calculate_minimum_redundancy(tdefl_sym_freq *A, int32 n)
		{
		    int32 root, leaf, next, avbl, used, dpth;
		    if (n == 0)
		        return;
		    else if (n == 1)
		    {
		        A[0].m_key = 1;
		        return;
		    }
		    A[0].m_key += A[1].m_key;
		    root = 0;
		    leaf = 2;
		    for (next = 1; next < n - 1; next++)
		    {
		        if (leaf >= n || A[root].m_key < A[leaf].m_key)
		        {
		            A[next].m_key = A[root].m_key;
		            A[root++].m_key = (mz_uint16)next;
		        }
		        else
		            A[next].m_key = A[leaf++].m_key;
		        if (leaf >= n || (root < next && A[root].m_key < A[leaf].m_key))
		        {
		            A[next].m_key = (mz_uint16)(A[next].m_key + A[root].m_key);
		            A[root++].m_key = (mz_uint16)next;
		        }
		        else
		            A[next].m_key = (mz_uint16)(A[next].m_key + A[leaf++].m_key);
		    }
		    A[n - 2].m_key = 0;
		    for (next = n - 3; next >= 0; next--)
		        A[next].m_key = A[A[next].m_key].m_key + 1;
		    avbl = 1;
		    used = dpth = 0;
		    root = n - 2;
		    next = n - 1;
		    while (avbl > 0)
		    {
		        while (root >= 0 && (int32)A[root].m_key == dpth)
		        {
		            used++;
		            root--;
		        }
		        while (avbl > used)
		        {
		            A[next--].m_key = (mz_uint16)(dpth);
		            avbl--;
		        }
		        avbl = 2 * used;
		        dpth++;
		        used = 0;
		    }
		}

		/* Limits canonical Huffman code table's max code size. */
		const int32 TDEFL_MAX_SUPPORTED_HUFF_CODESIZE = 32;

		static void tdefl_huffman_enforce_max_code_size(int32 *pNum_codes, int32 code_list_len, int32 max_code_size)
		{
		    int32 i;
		    mz_uint32 total = 0;
		    if (code_list_len <= 1)
		        return;
		    for (i = max_code_size + 1; i <= TDEFL_MAX_SUPPORTED_HUFF_CODESIZE; i++)
		        pNum_codes[max_code_size] += pNum_codes[i];
		    for (i = max_code_size; i > 0; i--)
		        total += (((mz_uint32)pNum_codes[i]) << (max_code_size - i));
		    while (total != (1UL << max_code_size))
		    {
		        pNum_codes[max_code_size]--;
		        for (i = max_code_size - 1; i > 0; i--)
		            if (pNum_codes[i] != 0)
		            {
		                pNum_codes[i]--;
		                pNum_codes[i + 1] += 2;
		                break;
		            }
		        total--;
		    }
		}

		static void tdefl_optimize_huffman_table(tdefl_compressor *d, int32 table_num, int32 table_len, int32 code_size_limit, bool static_table)
		{
		    int32 i, j, l;
			int32[1 + TDEFL_MAX_SUPPORTED_HUFF_CODESIZE] num_codes = .();
		    mz_uint[TDEFL_MAX_SUPPORTED_HUFF_CODESIZE + 1] next_code;
		    if (static_table)
		    {
		        for (i = 0; i < table_len; i++)
		            num_codes[d.m_huff_code_sizes[table_num][i]]++;
		    }
		    else
		    {
		        tdefl_sym_freq[TDEFL_MAX_HUFF_SYMBOLS] syms0 = .(), syms1 = .();
				tdefl_sym_freq* pSyms;
		        int32 num_used_syms = 0; // @change was uint32 before . indexes into array of size 288, so does not matter
		        mz_uint16 *pSym_count = &d.m_huff_count[table_num][0];
		        for (i = 0; i < table_len; i++)
		            if (pSym_count[i] != 0)
		            {
		                syms0[num_used_syms].m_key = (mz_uint16)pSym_count[i];
		                syms0[num_used_syms++].m_sym_index = (mz_uint16)i;
		            }

		        pSyms = tdefl_radix_sort_syms((.)num_used_syms, &syms0[0], &syms1[0]);
		        tdefl_calculate_minimum_redundancy(pSyms, num_used_syms);

		        for (i = 0; i < num_used_syms; i++)
		            num_codes[pSyms[i].m_key]++;

		        tdefl_huffman_enforce_max_code_size(&num_codes[0], num_used_syms, code_size_limit);

				d.m_huff_code_sizes[table_num] = .();
				d.m_huff_codes[table_num] = .();
		        for (i = 1, j = num_used_syms; i <= code_size_limit; i++)
		            for (l = num_codes[i]; l > 0; l--)
		                d.m_huff_code_sizes[table_num][pSyms[--j].m_sym_index] = (mz_uint8)(i);
		    }

		    next_code[1] = 0;
		    for (j = 0, i = 2; i <= code_size_limit; i++)
		        next_code[i] = (.)(j = ((j + num_codes[i - 1]) << 1));

		    for (i = 0; i < table_len; i++)
		    {
		        mz_uint rev_code = 0, code;
				int32 code_size; // @change was mz_uint before . is set from uint8 array element, so does not matter
		        if ((code_size = d.m_huff_code_sizes[table_num][i]) == 0)
		            continue;
		        code = next_code[code_size]++;
		        for (l = code_size; l > 0; l--, code >>= 1)
		            rev_code = (rev_code << 1) | (code & 1);
		        d.m_huff_codes[table_num][i] = (mz_uint16)rev_code;
		    }
		}

		static mixin TDEFL_PUT_BITS(var b, var l, var d)
		{
			mz_uint32 bits = (.)b;
			mz_uint32 len = (.)l;
			Debug.Assert(bits <= ((1U << len) - 1U));
			d.m_bit_buffer |= (bits << d.m_bits_in);
			d.m_bits_in += len;
			while (d.m_bits_in >= 8)
			{
			    if (d.m_pOutput_buf < d.m_pOutput_buf_end)
			        *d.m_pOutput_buf++ = (mz_uint8)(d.m_bit_buffer);
			    d.m_bit_buffer >>= 8;
			    d.m_bits_in -= 8;
			}
		}

		static mz_uint8[?] s_tdefl_packed_code_size_syms_swizzle = .( 16, 17, 18, 0, 8, 7, 9, 6, 10, 5, 11, 4, 12, 3, 13, 2, 14, 1, 15 );

		static void tdefl_start_dynamic_block(tdefl_compressor *d)
		{
		    int32 num_lit_codes, num_dist_codes, num_bit_lengths;
		    mz_uint i, total_code_sizes_to_pack, num_packed_code_sizes, rle_z_count, rle_repeat_count, packed_code_sizes_index;
		    mz_uint8[TDEFL_MAX_HUFF_SYMBOLS_0 + TDEFL_MAX_HUFF_SYMBOLS_1] code_sizes_to_pack = default, packed_code_sizes = default;
			mz_uint8 prev_code_size = 0xFF;

		    d.m_huff_count[0][256] = 1;

		    tdefl_optimize_huffman_table(d, 0, TDEFL_MAX_HUFF_SYMBOLS_0, 15, false);
		    tdefl_optimize_huffman_table(d, 1, TDEFL_MAX_HUFF_SYMBOLS_1, 15, false);

		    for (num_lit_codes = 286; num_lit_codes > 257; num_lit_codes--)
		        if (d.m_huff_code_sizes[0][num_lit_codes - 1] != 0)
		            break;
		    for (num_dist_codes = 30; num_dist_codes > 1; num_dist_codes--)
		        if (d.m_huff_code_sizes[1][num_dist_codes - 1] != 0)
		            break;

		    memcpy(&code_sizes_to_pack, &d.m_huff_code_sizes[0][0], num_lit_codes);
		    memcpy(&code_sizes_to_pack[num_lit_codes], &d.m_huff_code_sizes[1][0], num_dist_codes);
		    total_code_sizes_to_pack = (.)num_lit_codes + (.)num_dist_codes; // @change . cast is safe, see values they are set to above
		    num_packed_code_sizes = 0;
		    rle_z_count = 0;
		    rle_repeat_count = 0;

			mixin TDEFL_RLE_PREV_CODE_SIZE()
			{
				if (rle_repeat_count != 0)
				{
					if (rle_repeat_count < 3)
					{
						d.m_huff_count[2][prev_code_size] = (mz_uint16)(d.m_huff_count[2][prev_code_size] + rle_repeat_count);
						while ((rle_repeat_count--) != 0)
							packed_code_sizes[num_packed_code_sizes++] = prev_code_size;
					}
					else
					{
						d.m_huff_count[2][16] = (mz_uint16)(d.m_huff_count[2][16] + 1);
						packed_code_sizes[num_packed_code_sizes++] = 16;
						packed_code_sizes[num_packed_code_sizes++] = (mz_uint8)(rle_repeat_count - 3);
					}
					rle_repeat_count = 0;
				}
			}

			mixin TDEFL_RLE_ZERO_CODE_SIZE()
			{
				if (rle_z_count != 0)
				{
					if (rle_z_count < 3)
					{
						d.m_huff_count[2][0] = (mz_uint16)(d.m_huff_count[2][0] + rle_z_count);
						while ((rle_z_count--) != 0)
							packed_code_sizes[num_packed_code_sizes++] = 0;
					}
					else if (rle_z_count <= 10)
					{
						d.m_huff_count[2][17] = (mz_uint16)(d.m_huff_count[2][17] + 1);
						packed_code_sizes[num_packed_code_sizes++] = 17;
						packed_code_sizes[num_packed_code_sizes++] = (mz_uint8)(rle_z_count - 3);
					}
					else
					{
						d.m_huff_count[2][18] = (mz_uint16)(d.m_huff_count[2][18] + 1);
						packed_code_sizes[num_packed_code_sizes++] = 18;
						packed_code_sizes[num_packed_code_sizes++] = (mz_uint8)(rle_z_count - 11);
					}
					rle_z_count = 0;
				}
			}

		    memset(&d.m_huff_count[2][0], 0, sizeof(decltype(d.m_huff_count[2][0])) * TDEFL_MAX_HUFF_SYMBOLS_2);
		    for (i = 0; i < total_code_sizes_to_pack; i++)
		    {
		        mz_uint8 code_size = code_sizes_to_pack[i];
		        if (code_size == 0)
		        {
		            TDEFL_RLE_PREV_CODE_SIZE!();
		            if (++rle_z_count == 138)
		            {
		                TDEFL_RLE_ZERO_CODE_SIZE!();
		            }
		        }
		        else
		        {
		            TDEFL_RLE_ZERO_CODE_SIZE!();
		            if (code_size != prev_code_size)
		            {
		                TDEFL_RLE_PREV_CODE_SIZE!();
		                d.m_huff_count[2][code_size] = (mz_uint16)(d.m_huff_count[2][code_size] + 1);
		                packed_code_sizes[num_packed_code_sizes++] = code_size;
		            }
		            else if (++rle_repeat_count == 6)
		            {
		                TDEFL_RLE_PREV_CODE_SIZE!();
		            }
		        }
		        prev_code_size = code_size;
		    }
		    if (rle_repeat_count != 0)
		    {
		        TDEFL_RLE_PREV_CODE_SIZE!();
		    }
		    else
		    {
		        TDEFL_RLE_ZERO_CODE_SIZE!();
		    }

		    tdefl_optimize_huffman_table(d, 2, TDEFL_MAX_HUFF_SYMBOLS_2, 7, false);

		    TDEFL_PUT_BITS!(2, 2, d);

		    TDEFL_PUT_BITS!(num_lit_codes - 257, 5, d);
		    TDEFL_PUT_BITS!(num_dist_codes - 1, 5, d);

		    for (num_bit_lengths = 18; num_bit_lengths >= 0; num_bit_lengths--)
		        if (d.m_huff_code_sizes[2][s_tdefl_packed_code_size_syms_swizzle[num_bit_lengths]] != 0)
		            break;
		    num_bit_lengths = MZ_MAX!(4, (num_bit_lengths + 1));
		    TDEFL_PUT_BITS!(num_bit_lengths - 4, 4, d);
		    for (i = 0; (int)i < num_bit_lengths; i++)
		        TDEFL_PUT_BITS!(d.m_huff_code_sizes[2][s_tdefl_packed_code_size_syms_swizzle[i]], 3, d);

		    for (packed_code_sizes_index = 0; packed_code_sizes_index < num_packed_code_sizes;)
		    {
		        mz_uint code = packed_code_sizes[packed_code_sizes_index++];
		        Debug.Assert(code < TDEFL_MAX_HUFF_SYMBOLS_2);
		        TDEFL_PUT_BITS!(d.m_huff_codes[2][code], d.m_huff_code_sizes[2][code], d);
		        if (code >= 16)
				{
					mz_uint32 len = ?; // @change
					switch (code - 16)
					{
					case 0: len = 2;
					case 1: len = 3;
					case 2: len = 7;
					default:
						Debug.FatalError();
					}
		            TDEFL_PUT_BITS!(packed_code_sizes[packed_code_sizes_index++], len, d);
				}
		    }
		}

		static void tdefl_start_static_block(tdefl_compressor *d)
		{
		    mz_uint i;
		    mz_uint8 *p = &d.m_huff_code_sizes[0][0];

		    for (i = 0; i <= 143; ++i)
		        *p++ = 8;
		    for (; i <= 255; ++i)
		        *p++ = 9;
		    for (; i <= 279; ++i)
		        *p++ = 7;
		    for (; i <= 287; ++i)
		        *p++ = 8;

		    memset(&d.m_huff_code_sizes[1], 5, 32);

		    tdefl_optimize_huffman_table(d, 0, 288, 15, true);
		    tdefl_optimize_huffman_table(d, 1, 32, 15, true);

		    TDEFL_PUT_BITS!(1, 2, d);
		}

		static mz_uint[17] mz_bitmasks = .(0x0000, 0x0001, 0x0003, 0x0007, 0x000F, 0x001F, 0x003F, 0x007F, 0x00FF, 0x01FF, 0x03FF, 0x07FF, 0x0FFF, 0x1FFF, 0x3FFF, 0x7FFF, 0xFFFF );

#if MINIZ_USE_UNALIGNED_LOADS_AND_STORES && MINIZ_LITTLE_ENDIAN && MINIZ_HAS_64BIT_REGISTERS
		static bool tdefl_compress_lz_codes(tdefl_compressor *d)
		{
		    mz_uint flags;
		    mz_uint8 *pLZ_codes;
		    mz_uint8 *pOutput_buf = d.m_pOutput_buf;
		    mz_uint8 *pLZ_code_buf_end = d.m_pLZ_code_buf;
		    mz_uint64 bit_buffer = d.m_bit_buffer;
		    mz_uint bits_in = d.m_bits_in;

			mixin TDEFL_PUT_BITS_FAST(var b, var l)
			{
				bit_buffer |= (((mz_uint64)(b)) << bits_in);
				bits_in += (l);
			}

		    flags = 1;
		    for (pLZ_codes = &d.m_lz_code_buf; pLZ_codes < pLZ_code_buf_end; flags >>= 1)
		    {
		        if (flags == 1)
		            flags = (.)(*pLZ_codes++ | 0x100); // @change

		        if ((flags & 1) != 0)
		        {
		            mz_uint s0, s1, n0, n1, sym, num_extra_bits;
		            mz_uint match_len = pLZ_codes[0], match_dist = *(mz_uint16*)(pLZ_codes + 1);
		            pLZ_codes += 3;

		            Debug.Assert(d.m_huff_code_sizes[0][s_tdefl_len_sym[match_len]] != 0);
		            TDEFL_PUT_BITS_FAST!(d.m_huff_codes[0][s_tdefl_len_sym[match_len]], d.m_huff_code_sizes[0][s_tdefl_len_sym[match_len]]);
		            TDEFL_PUT_BITS_FAST!(match_len & mz_bitmasks[s_tdefl_len_extra[match_len]], s_tdefl_len_extra[match_len]);

		            /* This sequence coaxes MSVC into using cmov's vs. jmp's. */
		            s0 = s_tdefl_small_dist_sym[match_dist & 511];
		            n0 = s_tdefl_small_dist_extra[match_dist & 511];
		            s1 = s_tdefl_large_dist_sym[match_dist >> 8];
		            n1 = s_tdefl_large_dist_extra[match_dist >> 8];
		            sym = (match_dist < 512) ? s0 : s1;
		            num_extra_bits = (match_dist < 512) ? n0 : n1;

		            Debug.Assert(d.m_huff_code_sizes[1][sym] != 0);
		            TDEFL_PUT_BITS_FAST!(d.m_huff_codes[1][sym], d.m_huff_code_sizes[1][sym]);
		            TDEFL_PUT_BITS_FAST!(match_dist & mz_bitmasks[num_extra_bits], num_extra_bits);
		        }
		        else
		        {
		            mz_uint lit = *pLZ_codes++;
		            Debug.Assert(d.m_huff_code_sizes[0][lit] != 0);
		            TDEFL_PUT_BITS_FAST!(d.m_huff_codes[0][lit], d.m_huff_code_sizes[0][lit]);

		            if (((flags & 2) == 0) && (pLZ_codes < pLZ_code_buf_end))
		            {
		                flags >>= 1;
		                lit = *pLZ_codes++;
		                Debug.Assert(d.m_huff_code_sizes[0][lit] != 0);
		                TDEFL_PUT_BITS_FAST!(d.m_huff_codes[0][lit], d.m_huff_code_sizes[0][lit]);

		                if (((flags & 2) == 0) && (pLZ_codes < pLZ_code_buf_end))
		                {
		                    flags >>= 1;
		                    lit = *pLZ_codes++;
		                    Debug.Assert(d.m_huff_code_sizes[0][lit] != 0);
		                    TDEFL_PUT_BITS_FAST!(d.m_huff_codes[0][lit], d.m_huff_code_sizes[0][lit]);
		                }
		            }
		        }

		        if (pOutput_buf >= d.m_pOutput_buf_end)
		            return false;

		        *(mz_uint64 *)pOutput_buf = bit_buffer;
		        pOutput_buf += (bits_in >> 3);
		        bit_buffer >>= (bits_in & ~7);
		        bits_in &= 7;
		    }

		    d.m_pOutput_buf = pOutput_buf;
		    d.m_bits_in = 0;
		    d.m_bit_buffer = 0;

		    while (bits_in != 0)
		    {
		        mz_uint32 n = MZ_MIN!(bits_in, 16);
		        TDEFL_PUT_BITS!((mz_uint)bit_buffer & mz_bitmasks[n], n, d);
		        bit_buffer >>= n;
		        bits_in -= n;
		    }

		    TDEFL_PUT_BITS!(d.m_huff_codes[0][256], d.m_huff_code_sizes[0][256], d);

		    return (d.m_pOutput_buf < d.m_pOutput_buf_end);
		}
#else
		static bool tdefl_compress_lz_codes(tdefl_compressor *d)
		{
		    mz_uint flags;
		    mz_uint8 *pLZ_codes;

		    flags = 1;
		    for (pLZ_codes = &d.m_lz_code_buf; pLZ_codes < d.m_pLZ_code_buf; flags >>= 1)
		    {
		        if (flags == 1)
		            flags = (.)(*pLZ_codes++ | 0x100); // @change
		        if ((flags & 1) != 0)
		        {
		            mz_uint sym, num_extra_bits;
		            mz_uint match_len = pLZ_codes[0], match_dist = (pLZ_codes[1] | ((mz_uint)pLZ_codes[2] << 8)); // @change add cast
		            pLZ_codes += 3;

		            Debug.Assert(d.m_huff_code_sizes[0][s_tdefl_len_sym[match_len]] != 0);
		            TDEFL_PUT_BITS!(d.m_huff_codes[0][s_tdefl_len_sym[match_len]], d.m_huff_code_sizes[0][s_tdefl_len_sym[match_len]], d);
		            TDEFL_PUT_BITS!(match_len & mz_bitmasks[s_tdefl_len_extra[match_len]], s_tdefl_len_extra[match_len], d);

		            if (match_dist < 512)
		            {
		                sym = s_tdefl_small_dist_sym[match_dist];
		                num_extra_bits = s_tdefl_small_dist_extra[match_dist];
		            }
		            else
		            {
		                sym = s_tdefl_large_dist_sym[match_dist >> 8];
		                num_extra_bits = s_tdefl_large_dist_extra[match_dist >> 8];
		            }
		            Debug.Assert(d.m_huff_code_sizes[1][sym] != 0);
		            TDEFL_PUT_BITS!(d.m_huff_codes[1][sym], d.m_huff_code_sizes[1][sym], d);
		            TDEFL_PUT_BITS!(match_dist & mz_bitmasks[num_extra_bits], num_extra_bits, d);
		        }
		        else
		        {
		            mz_uint lit = *pLZ_codes++;
		            Debug.Assert(d.m_huff_code_sizes[0][lit] != 0);
		            TDEFL_PUT_BITS!(d.m_huff_codes[0][lit], d.m_huff_code_sizes[0][lit], d);
		        }
		    }

		    TDEFL_PUT_BITS!(d.m_huff_codes[0][256], d.m_huff_code_sizes[0][256], d);

		    return (d.m_pOutput_buf < d.m_pOutput_buf_end);
		}
#endif /* MINIZ_USE_UNALIGNED_LOADS_AND_STORES && MINIZ_LITTLE_ENDIAN && MINIZ_HAS_64BIT_REGISTERS */

		static bool tdefl_compress_block(tdefl_compressor* d, bool static_block)
		{
		    if (static_block)
		        tdefl_start_static_block(d);
		    else
		        tdefl_start_dynamic_block(d);
		    return tdefl_compress_lz_codes(d);
		}

		static int32 tdefl_flush_block(tdefl_compressor* d, tdefl_flush flush)
		{
		    mz_uint saved_bit_buf, saved_bits_in;
		    mz_uint8 *pSaved_output_buf;
		    bool comp_block_succeeded = false;
		    int32 n;
			bool use_raw_block = ((d.m_flags & .TDEFL_FORCE_ALL_RAW_BLOCKS) != 0) && (d.m_lookahead_pos - d.m_lz_code_buf_dict_pos) <= d.m_dict_size;
		    mz_uint8 *pOutput_buf_start = ((d.m_pPut_buf_func == null) && ((*d.m_pOut_buf_size - d.m_out_buf_ofs) >= TDEFL_OUT_BUF_SIZE)) ? (((mz_uint8*)d.m_pOut_buf) + d.m_out_buf_ofs) : &d.m_output_buf[0];

		    d.m_pOutput_buf = pOutput_buf_start;
		    d.m_pOutput_buf_end = d.m_pOutput_buf + TDEFL_OUT_BUF_SIZE - 16;

		    Debug.Assert(d.m_output_flush_remaining == 0);
		    d.m_output_flush_ofs = 0;
		    d.m_output_flush_remaining = 0;

		    *d.m_pLZ_flags = (mz_uint8)(*d.m_pLZ_flags >> d.m_num_flags_left);
		    d.m_pLZ_code_buf -= (d.m_num_flags_left == 8) ? 1 : 0;

		    if ((d.m_flags & .TDEFL_WRITE_ZLIB_HEADER) != 0 && (d.m_block_index == 0))
		    {
		        TDEFL_PUT_BITS!(0x78, 8, d);
		        TDEFL_PUT_BITS!(0x01, 8, d);
		    }

		    TDEFL_PUT_BITS!((flush == .TDEFL_FINISH) ? 1 : 0, 1, d);

		    pSaved_output_buf = d.m_pOutput_buf;
		    saved_bit_buf = d.m_bit_buffer;
		    saved_bits_in = d.m_bits_in;

		    if (!use_raw_block)
		        comp_block_succeeded = tdefl_compress_block(d, (d.m_flags & .TDEFL_FORCE_ALL_STATIC_BLOCKS) != 0 || (d.m_total_lz_bytes < 48));

		    /* If the block gets expanded, forget the current contents of the output buffer and send a raw block instead. */
		    if (((use_raw_block) || ((d.m_total_lz_bytes != 0) && ((d.m_pOutput_buf - pSaved_output_buf + 1U) >= d.m_total_lz_bytes))) &&
		        ((d.m_lookahead_pos - d.m_lz_code_buf_dict_pos) <= d.m_dict_size))
		    {
		        mz_uint i;
		        d.m_pOutput_buf = pSaved_output_buf;
		        d.m_bit_buffer = saved_bit_buf;
				d.m_bits_in = saved_bits_in;
		        TDEFL_PUT_BITS!(0, 2, d);
		        if (d.m_bits_in != 0)
		        {
		            TDEFL_PUT_BITS!(0, 8 - d.m_bits_in, d);
		        }
		        for (i = 2; i != 0; --i, d.m_total_lz_bytes ^= 0xFFFF)
		        {
		            TDEFL_PUT_BITS!(d.m_total_lz_bytes & 0xFFFF, 16, d);
		        }
		        for (i = 0; i < d.m_total_lz_bytes; ++i)
		        {
		            TDEFL_PUT_BITS!(d.m_dict[(d.m_lz_code_buf_dict_pos + i) & TDEFL_LZ_DICT_SIZE_MASK], 8, d);
		        }
		    }
		    /* Check for the extremely unlikely (if not impossible) case of the compressed block not fitting into the output buffer when using dynamic codes. */
		    else if (!comp_block_succeeded)
		    {
		        d.m_pOutput_buf = pSaved_output_buf;
		        d.m_bit_buffer = saved_bit_buf;
				d.m_bits_in = saved_bits_in;
		        tdefl_compress_block(d, true);
		    }

		    if (flush != 0)
		    {
		        if (flush == .TDEFL_FINISH)
		        {
		            if (d.m_bits_in != 0)
		            {
		                TDEFL_PUT_BITS!(0, 8 - d.m_bits_in, d);
		            }
		            if ((d.m_flags & .TDEFL_WRITE_ZLIB_HEADER) != 0)
		            {
		                mz_uint i, a = d.m_adler32;
		                for (i = 0; i < 4; i++)
		                {
		                    TDEFL_PUT_BITS!((a >> 24) & 0xFF, 8, d);
		                    a <<= 8;
		                }
		            }
		        }
		        else
		        {
		            mz_uint i, z = 0;
		            TDEFL_PUT_BITS!(0, 3, d);
		            if (d.m_bits_in != 0)
		            {
		                TDEFL_PUT_BITS!(0, 8 - d.m_bits_in, d);
		            }
		            for (i = 2; i != 0; --i, z ^= 0xFFFF)
		            {
		                TDEFL_PUT_BITS!(z & 0xFFFF, 16, d);
		            }
		        }
		    }

		    Debug.Assert(d.m_pOutput_buf < d.m_pOutput_buf_end);

		    memset(&d.m_huff_count[0][0], 0, sizeof(decltype(d.m_huff_count[0][0])) * TDEFL_MAX_HUFF_SYMBOLS_0); // @check does this work?
		    memset(&d.m_huff_count[1][0], 0, sizeof(decltype(d.m_huff_count[1][0])) * TDEFL_MAX_HUFF_SYMBOLS_1);

		    d.m_pLZ_code_buf = &d.m_lz_code_buf[0] + 1;
		    d.m_pLZ_flags = &d.m_lz_code_buf[0];
		    d.m_num_flags_left = 8;
		    d.m_lz_code_buf_dict_pos += d.m_total_lz_bytes;
		    d.m_total_lz_bytes = 0;
		    d.m_block_index++;

		    if ((n = (int32)(d.m_pOutput_buf - pOutput_buf_start)) != 0)
		    {
		        if (d.m_pPut_buf_func != 0)
		        {
		            *d.m_pIn_buf_size = d.m_pSrc - (mz_uint8*)d.m_pIn_buf;
		            if (!d.m_pPut_buf_func(&d.m_output_buf[0], n, d.m_pPut_buf_user))
		                return (int32)(d.m_prev_return_status = .TDEFL_STATUS_PUT_BUF_FAILED);
		        }
		        else if (pOutput_buf_start == &d.m_output_buf[0])
		        {
		            int32 bytes_to_copy = (int32)MZ_MIN!((size_t)n, (size_t)(*d.m_pOut_buf_size - d.m_out_buf_ofs));
		            memcpy(((mz_uint8 *)d.m_pOut_buf) + d.m_out_buf_ofs, &d.m_output_buf[0], bytes_to_copy);
		            d.m_out_buf_ofs += bytes_to_copy;
		            if ((n -= bytes_to_copy) != 0)
		            {
		                d.m_output_flush_ofs = (.)bytes_to_copy; // @change
		                d.m_output_flush_remaining = (.)n;
		            }
		        }
		        else
		        {
		            d.m_out_buf_ofs += n;
		        }
		    }

		    return (.)d.m_output_flush_remaining; // @change
		}

#if MINIZ_USE_UNALIGNED_LOADS_AND_STORES
#if MINIZ_UNALIGNED_USE_MEMCPY
		static mixin TDEFL_READ_UNALIGNED_WORD(mz_uint8* p)
		{
			mz_uint16 ret = ?;
			memcpy(&ret, p, sizeof(mz_uint16));
			ret
		}
		static mixin TDEFL_READ_UNALIGNED_WORD2(mz_uint16* ptr)
		{
			mz_uint16 ret = ?;
			memcpy(&ret, ptr, sizeof(mz_uint16));
			ret
		}
#else
		static mixin TDEFL_READ_UNALIGNED_WORD(var p)
		{
			*(mz_uint16 *)(p)
		}
		static mixin TDEFL_READ_UNALIGNED_WORD2(var p)
		{
			*(mz_uint16 *)(p)
		}
#endif
		[Inline]
		static void tdefl_find_match(tdefl_compressor *d, mz_uint lookahead_pos, mz_uint max_dist, mz_uint max_match_len, mz_uint *pMatch_dist, mz_uint *pMatch_len)
		{
		    mz_uint dist = 0, pos = lookahead_pos & TDEFL_LZ_DICT_SIZE_MASK, match_len = *pMatch_len, probe_pos = pos, next_probe_pos, probe_len;
		    mz_uint num_probes_left = d.m_max_probes[match_len >= 32 ? 1 : 0];
		    mz_uint16* s = (mz_uint16 *)(&d.m_dict[pos]), p, q;
		    mz_uint16 c01 = TDEFL_READ_UNALIGNED_WORD!(&d.m_dict[pos + match_len - 1]), s01 = TDEFL_READ_UNALIGNED_WORD2!(s);
		    Debug.Assert(max_match_len <= TDEFL_MAX_MATCH_LEN);
		    if (max_match_len <= match_len)
		        return;
		    for (;;)
		    {
		        for (;;)
		        {
		            if (--num_probes_left == 0)
		                return;

					mixin TDEFL_PROBE()
					{
						next_probe_pos = d.m_next[probe_pos];
						if ((next_probe_pos == 0) || ((dist = (mz_uint16)(lookahead_pos - next_probe_pos)) > max_dist))
							return;
						probe_pos = next_probe_pos & TDEFL_LZ_DICT_SIZE_MASK;
						if (TDEFL_READ_UNALIGNED_WORD!(&d.m_dict[probe_pos + match_len - 1]) == c01)
							break;

					}

		            TDEFL_PROBE!();
		            TDEFL_PROBE!();
		            TDEFL_PROBE!();
		        }
		        if (dist == 0)
		            break;
		        q = (mz_uint16*)(&d.m_dict[0] + probe_pos);
		        if (TDEFL_READ_UNALIGNED_WORD2!((q)) != s01) // @change doing q instead of (q) says the varaible is unitialized... weird bug?
		            continue;
		        p = s;
		        probe_len = 32;
		        repeat {} while ((TDEFL_READ_UNALIGNED_WORD2!(++p) == TDEFL_READ_UNALIGNED_WORD2!(++q)) && (TDEFL_READ_UNALIGNED_WORD2!(++p) == TDEFL_READ_UNALIGNED_WORD2!(++q)) &&
		                 (TDEFL_READ_UNALIGNED_WORD2!(++p) == TDEFL_READ_UNALIGNED_WORD2!(++q)) && (TDEFL_READ_UNALIGNED_WORD2!(++p) == TDEFL_READ_UNALIGNED_WORD2!(++q)) && (--probe_len > 0));
		        if (probe_len == 0)
		        {
		            *pMatch_dist = dist;
		            *pMatch_len = MZ_MIN!(max_match_len, (mz_uint)TDEFL_MAX_MATCH_LEN);
		            break;
		        }
		        else if ((probe_len = ((mz_uint)(p - s) * 2) + (mz_uint)(*(mz_uint8 *)p == *(mz_uint8 *)q)) > match_len)
		        {
		            *pMatch_dist = dist;
		            if ((*pMatch_len = match_len = MZ_MIN!(max_match_len, probe_len)) == max_match_len)
		                break;
		            c01 = TDEFL_READ_UNALIGNED_WORD!(&d.m_dict[pos + match_len - 1]);
		        }
		    }
		}
#else
		[Inline]
		static void tdefl_find_match(tdefl_compressor *d, mz_uint lookahead_pos, mz_uint max_dist, mz_uint max_match_len, mz_uint *pMatch_dist, mz_uint *pMatch_len)
		{
		    mz_uint dist = 0, pos = lookahead_pos & TDEFL_LZ_DICT_SIZE_MASK, match_len = *pMatch_len, probe_pos = pos, next_probe_pos, probe_len;
		    mz_uint num_probes_left = d.m_max_probes[match_len >= 32 ? 1 : 0];
		    mz_uint8* s = &d.m_dict[pos], p, q;
		    mz_uint8 c0 = d.m_dict[pos + match_len], c1 = d.m_dict[pos + match_len - 1];
		    Debug.Assert(max_match_len <= TDEFL_MAX_MATCH_LEN);
		    if (max_match_len <= match_len)
		        return;
		    for (;;)
		    {
		        for (;;)
		        {
		            if (--num_probes_left == 0)
		                return;

					mixin TDEFL_PROBE()
					{
						next_probe_pos = d.m_next[probe_pos];
						if ((next_probe_pos == 0) || ((dist = (mz_uint16)(lookahead_pos - next_probe_pos)) > max_dist))
							return;
						probe_pos = next_probe_pos & TDEFL_LZ_DICT_SIZE_MASK;
						if ((d.m_dict[probe_pos + match_len] == c0) && (d.m_dict[probe_pos + match_len - 1] == c1))
							break;
					}

		            TDEFL_PROBE!();
		            TDEFL_PROBE!();
		            TDEFL_PROBE!();
		        }
		        if (dist == 0)
		            break;
		        p = s;
		        q = &d.m_dict[0] + probe_pos;
		        for (probe_len = 0; probe_len < max_match_len; probe_len++)
		            if (*p++ != *q++)
		                break;
		        if (probe_len > match_len)
		        {
		            *pMatch_dist = dist;
		            if ((*pMatch_len = match_len = probe_len) == max_match_len)
		                return;
		            c0 = d.m_dict[pos + match_len];
		            c1 = d.m_dict[pos + match_len - 1];
		        }
		    }
		}
#endif /* #if MINIZ_USE_UNALIGNED_LOADS_AND_STORES */

#if MINIZ_USE_UNALIGNED_LOADS_AND_STORES && MINIZ_LITTLE_ENDIAN
#if MINIZ_UNALIGNED_USE_MEMCPY
		static mixin TDEFL_READ_UNALIGNED_WORD32(mz_uint8* p)
		{
			mz_uint32 ret = ?;
			memcpy(&ret, p, sizeof(mz_uint32));
			ret
		}
#else
		static mixin TDEFL_READ_UNALIGNED_WORD32(var p)
		{
			*(mz_uint32 *)(p)
		}
#endif
		static bool tdefl_compress_fast(tdefl_compressor *d)
		{
		    /* Faster, minimally featured LZRW1-style match+parse loop with better register utilization. Intended for applications where raw throughput is valued more highly than ratio. */
		    mz_uint lookahead_pos = d.m_lookahead_pos, lookahead_size = d.m_lookahead_size, dict_size = d.m_dict_size, total_lz_bytes = d.m_total_lz_bytes, num_flags_left = d.m_num_flags_left;
		    mz_uint8* pLZ_code_buf = d.m_pLZ_code_buf, pLZ_flags = d.m_pLZ_flags;
		    mz_uint cur_pos = lookahead_pos & TDEFL_LZ_DICT_SIZE_MASK;

		    while ((d.m_src_buf_left != 0) || ((d.m_flush != 0) && (lookahead_size != 0)))
		    {
		        const mz_uint TDEFL_COMP_FAST_LOOKAHEAD_SIZE = 4096;
		        mz_uint dst_pos = (lookahead_pos + lookahead_size) & TDEFL_LZ_DICT_SIZE_MASK;
		        mz_uint num_bytes_to_process = (mz_uint)MZ_MIN!(d.m_src_buf_left, TDEFL_COMP_FAST_LOOKAHEAD_SIZE - lookahead_size);
		        d.m_src_buf_left -= num_bytes_to_process;
		        lookahead_size += num_bytes_to_process;

		        while (num_bytes_to_process != 0)
		        {
		            mz_uint32 n = MZ_MIN!(TDEFL_LZ_DICT_SIZE - dst_pos, num_bytes_to_process);
		            memcpy(&d.m_dict[dst_pos], d.m_pSrc, n);
		            if (dst_pos < (TDEFL_MAX_MATCH_LEN - 1))
		                memcpy(&d.m_dict[TDEFL_LZ_DICT_SIZE + dst_pos], d.m_pSrc, MZ_MIN!(n, (TDEFL_MAX_MATCH_LEN - 1) - dst_pos));
		            d.m_pSrc += n;
		            dst_pos = (dst_pos + n) & TDEFL_LZ_DICT_SIZE_MASK;
		            num_bytes_to_process -= n;
		        }

		        dict_size = MZ_MIN!(TDEFL_LZ_DICT_SIZE - lookahead_size, dict_size);
		        if ((d.m_flush == 0) && (lookahead_size < TDEFL_COMP_FAST_LOOKAHEAD_SIZE))
		            break;

		        while (lookahead_size >= 4)
		        {
		            mz_uint cur_match_dist, cur_match_len = 1;
		            mz_uint8 *pCur_dict = &d.m_dict[cur_pos];
		            mz_uint first_trigram = TDEFL_READ_UNALIGNED_WORD32!(pCur_dict) & 0xFFFFFF;
		            mz_uint hash = (first_trigram ^ (first_trigram >> (24 - (TDEFL_LZ_HASH_BITS - 8)))) & TDEFL_LEVEL1_HASH_SIZE_MASK;
		            mz_uint probe_pos = d.m_hash[hash];
		            d.m_hash[hash] = (mz_uint16)lookahead_pos;

		            if (((cur_match_dist = (mz_uint16)(lookahead_pos - probe_pos)) <= dict_size) && ((TDEFL_READ_UNALIGNED_WORD32!(&d.m_dict[(probe_pos &= TDEFL_LZ_DICT_SIZE_MASK)]) & 0xFFFFFF) == first_trigram))
		            {
		                mz_uint16 *p = (mz_uint16 *)pCur_dict;
		                mz_uint16 *q = (mz_uint16 *)(&d.m_dict[probe_pos]);
		                mz_uint32 probe_len = 32;
		                repeat {} while ((TDEFL_READ_UNALIGNED_WORD2!(++p) == TDEFL_READ_UNALIGNED_WORD2!(++q)) && (TDEFL_READ_UNALIGNED_WORD2!(++p) == TDEFL_READ_UNALIGNED_WORD2!(++q)) &&
		                         (TDEFL_READ_UNALIGNED_WORD2!(++p) == TDEFL_READ_UNALIGNED_WORD2!(++q)) && (TDEFL_READ_UNALIGNED_WORD2!(++p) == TDEFL_READ_UNALIGNED_WORD2!(++q)) && (--probe_len > 0));
		                cur_match_len = ((mz_uint)(p - (mz_uint16 *)pCur_dict) * 2) + (mz_uint)(*(mz_uint8 *)p == *(mz_uint8 *)q);
		                if (probe_len == 0)
		                    cur_match_len = cur_match_dist != 0 ? TDEFL_MAX_MATCH_LEN : 0;

		                if ((cur_match_len < TDEFL_MIN_MATCH_LEN) || ((cur_match_len == TDEFL_MIN_MATCH_LEN) && (cur_match_dist >= 8U * 1024U)))
		                {
		                    cur_match_len = 1;
		                    *pLZ_code_buf++ = (mz_uint8)first_trigram;
		                    *pLZ_flags = (mz_uint8)(*pLZ_flags >> 1);
		                    d.m_huff_count[0][(mz_uint8)first_trigram]++;
		                }
		                else
		                {
		                    mz_uint32 s0, s1;
		                    cur_match_len = MZ_MIN!(cur_match_len, lookahead_size);

		                    Debug.Assert((cur_match_len >= TDEFL_MIN_MATCH_LEN) && (cur_match_dist >= 1) && (cur_match_dist <= TDEFL_LZ_DICT_SIZE));

		                    cur_match_dist--;

		                    pLZ_code_buf[0] = (mz_uint8)(cur_match_len - TDEFL_MIN_MATCH_LEN);
#if MINIZ_UNALIGNED_USE_MEMCPY
							memcpy(&pLZ_code_buf[1], &cur_match_dist, sizeof(decltype(cur_match_dist)));
#else
		                    *(mz_uint16 *)(&pLZ_code_buf[1]) = (mz_uint16)cur_match_dist;
#endif
		                    pLZ_code_buf += 3;
		                    *pLZ_flags = (mz_uint8)((*pLZ_flags >> 1) | 0x80);

		                    s0 = s_tdefl_small_dist_sym[cur_match_dist & 511];
		                    s1 = s_tdefl_large_dist_sym[cur_match_dist >> 8];
		                    d.m_huff_count[1][(cur_match_dist < 512) ? s0 : s1]++;

		                    d.m_huff_count[0][s_tdefl_len_sym[cur_match_len - TDEFL_MIN_MATCH_LEN]]++;
		                }
		            }
		            else
		            {
		                *pLZ_code_buf++ = (mz_uint8)first_trigram;
		                *pLZ_flags = (mz_uint8)(*pLZ_flags >> 1);
		                d.m_huff_count[0][(mz_uint8)first_trigram]++;
		            }

		            if (--num_flags_left == 0)
		            {
		                num_flags_left = 8;
		                pLZ_flags = pLZ_code_buf++;
		            }

		            total_lz_bytes += cur_match_len;
		            lookahead_pos += cur_match_len;
		            dict_size = MZ_MIN!(dict_size + cur_match_len, (mz_uint)TDEFL_LZ_DICT_SIZE);
		            cur_pos = (cur_pos + cur_match_len) & TDEFL_LZ_DICT_SIZE_MASK;
		            Debug.Assert(lookahead_size >= cur_match_len);
		            lookahead_size -= cur_match_len;

		            if (pLZ_code_buf > &d.m_lz_code_buf[TDEFL_LZ_CODE_BUF_SIZE - 8])
		            {
		                int32 n;
		                d.m_lookahead_pos = lookahead_pos;
		                d.m_lookahead_size = lookahead_size;
		                d.m_dict_size = dict_size;
		                d.m_total_lz_bytes = total_lz_bytes;
		                d.m_pLZ_code_buf = pLZ_code_buf;
		                d.m_pLZ_flags = pLZ_flags;
		                d.m_num_flags_left = num_flags_left;
		                if ((n = tdefl_flush_block(d, 0)) != 0)
		                    return (n < 0) ? false : true;
		                total_lz_bytes = d.m_total_lz_bytes;
		                pLZ_code_buf = d.m_pLZ_code_buf;
		                pLZ_flags = d.m_pLZ_flags;
		                num_flags_left = d.m_num_flags_left;
		            }
		        }

		        while (lookahead_size != 0)
		        {
		            mz_uint8 lit = d.m_dict[cur_pos];

		            total_lz_bytes++;
		            *pLZ_code_buf++ = lit;
		            *pLZ_flags = (mz_uint8)(*pLZ_flags >> 1);
		            if (--num_flags_left == 0)
		            {
		                num_flags_left = 8;
		                pLZ_flags = pLZ_code_buf++;
		            }

		            d.m_huff_count[0][lit]++;

		            lookahead_pos++;
		            dict_size = MZ_MIN!(dict_size + 1, (mz_uint)TDEFL_LZ_DICT_SIZE);
		            cur_pos = (cur_pos + 1) & TDEFL_LZ_DICT_SIZE_MASK;
		            lookahead_size--;

		            if (pLZ_code_buf > &d.m_lz_code_buf[TDEFL_LZ_CODE_BUF_SIZE - 8])
		            {
		                int n;
		                d.m_lookahead_pos = lookahead_pos;
		                d.m_lookahead_size = lookahead_size;
		                d.m_dict_size = dict_size;
		                d.m_total_lz_bytes = total_lz_bytes;
		                d.m_pLZ_code_buf = pLZ_code_buf;
		                d.m_pLZ_flags = pLZ_flags;
		                d.m_num_flags_left = num_flags_left;
		                if ((n = tdefl_flush_block(d, 0)) != 0)
		                    return (n < 0) ? false : true;
		                total_lz_bytes = d.m_total_lz_bytes;
		                pLZ_code_buf = d.m_pLZ_code_buf;
		                pLZ_flags = d.m_pLZ_flags;
		                num_flags_left = d.m_num_flags_left;
		            }
		        }
		    }

		    d.m_lookahead_pos = lookahead_pos;
		    d.m_lookahead_size = lookahead_size;
		    d.m_dict_size = dict_size;
		    d.m_total_lz_bytes = total_lz_bytes;
		    d.m_pLZ_code_buf = pLZ_code_buf;
		    d.m_pLZ_flags = pLZ_flags;
		    d.m_num_flags_left = num_flags_left;
		    return true;
		}
#endif /* MINIZ_USE_UNALIGNED_LOADS_AND_STORES && MINIZ_LITTLE_ENDIAN */

		[Inline]
		static void tdefl_record_literal(tdefl_compressor *d, mz_uint8 lit)
		{
		    d.m_total_lz_bytes++;
		    *d.m_pLZ_code_buf++ = lit;
		    *d.m_pLZ_flags = (mz_uint8)(*d.m_pLZ_flags >> 1);
		    if (--d.m_num_flags_left == 0)
		    {
		        d.m_num_flags_left = 8;
		        d.m_pLZ_flags = d.m_pLZ_code_buf++;
		    }
		    d.m_huff_count[0][lit]++;
		}

		[Inline]
		static void tdefl_record_match(tdefl_compressor *d, mz_uint match_len, mz_uint match_dist)
		{
		    mz_uint32 s0, s1;
			var match_dist;

		    Debug.Assert((match_len >= TDEFL_MIN_MATCH_LEN) && (match_dist >= 1) && (match_dist <= TDEFL_LZ_DICT_SIZE));

		    d.m_total_lz_bytes += match_len;

		    d.m_pLZ_code_buf[0] = (mz_uint8)(match_len - TDEFL_MIN_MATCH_LEN);

		    match_dist -= 1;
		    d.m_pLZ_code_buf[1] = (mz_uint8)(match_dist & 0xFF);
		    d.m_pLZ_code_buf[2] = (mz_uint8)(match_dist >> 8);
		    d.m_pLZ_code_buf += 3;

		    *d.m_pLZ_flags = (mz_uint8)((*d.m_pLZ_flags >> 1) | 0x80);
		    if (--d.m_num_flags_left == 0)
		    {
		        d.m_num_flags_left = 8;
		        d.m_pLZ_flags = d.m_pLZ_code_buf++;
		    }

		    s0 = s_tdefl_small_dist_sym[match_dist & 511];
		    s1 = s_tdefl_large_dist_sym[(match_dist >> 8) & 127];
		    d.m_huff_count[1][(match_dist < 512) ? s0 : s1]++;

		    if (match_len >= TDEFL_MIN_MATCH_LEN)
		        d.m_huff_count[0][s_tdefl_len_sym[match_len - TDEFL_MIN_MATCH_LEN]]++;
		}

		static bool tdefl_compress_normal(tdefl_compressor *d)
		{
		    mz_uint8 *pSrc = d.m_pSrc;
		    size_t src_buf_left = d.m_src_buf_left;
		    tdefl_flush flush = d.m_flush;

		    while ((src_buf_left != 0) || ((flush != 0) && (d.m_lookahead_size != 0)))
		    {
		        mz_uint len_to_move, cur_match_dist, cur_match_len, cur_pos;
		        /* Update dictionary and hash chains. Keeps the lookahead size equal to TDEFL_MAX_MATCH_LEN. */
		        if ((d.m_lookahead_size + d.m_dict_size) >= (TDEFL_MIN_MATCH_LEN - 1))
		        {
		            mz_uint dst_pos = (d.m_lookahead_pos + d.m_lookahead_size) & TDEFL_LZ_DICT_SIZE_MASK, ins_pos = d.m_lookahead_pos + d.m_lookahead_size - 2;
		            mz_uint hash = (d.m_dict[ins_pos & TDEFL_LZ_DICT_SIZE_MASK] << TDEFL_LZ_HASH_SHIFT) ^ d.m_dict[(ins_pos + 1) & TDEFL_LZ_DICT_SIZE_MASK];
		            mz_uint num_bytes_to_process = (mz_uint)MZ_MIN!(src_buf_left, TDEFL_MAX_MATCH_LEN - d.m_lookahead_size);
		            mz_uint8 *pSrc_end = pSrc + num_bytes_to_process;
		            src_buf_left -= num_bytes_to_process;
		            d.m_lookahead_size += num_bytes_to_process;
		            while (pSrc != pSrc_end)
		            {
		                mz_uint8 c = *pSrc++;
		                d.m_dict[dst_pos] = c;
		                if (dst_pos < (TDEFL_MAX_MATCH_LEN - 1))
		                    d.m_dict[TDEFL_LZ_DICT_SIZE + dst_pos] = c;
		                hash = ((hash << TDEFL_LZ_HASH_SHIFT) ^ c) & (TDEFL_LZ_HASH_SIZE - 1);
		                d.m_next[ins_pos & TDEFL_LZ_DICT_SIZE_MASK] = d.m_hash[hash];
		                d.m_hash[hash] = (mz_uint16)(ins_pos);
		                dst_pos = (dst_pos + 1) & TDEFL_LZ_DICT_SIZE_MASK;
		                ins_pos++;
		            }
		        }
		        else
		        {
		            while ((src_buf_left != 0) && (d.m_lookahead_size < TDEFL_MAX_MATCH_LEN))
		            {
		                mz_uint8 c = *pSrc++;
		                mz_uint dst_pos = (d.m_lookahead_pos + d.m_lookahead_size) & TDEFL_LZ_DICT_SIZE_MASK;
		                src_buf_left--;
		                d.m_dict[dst_pos] = c;
		                if (dst_pos < (TDEFL_MAX_MATCH_LEN - 1))
		                    d.m_dict[TDEFL_LZ_DICT_SIZE + dst_pos] = c;
		                if ((++d.m_lookahead_size + d.m_dict_size) >= TDEFL_MIN_MATCH_LEN)
		                {
		                    mz_uint ins_pos = d.m_lookahead_pos + (d.m_lookahead_size - 1) - 2;
		                    mz_uint hash = (((mz_uint)d.m_dict[ins_pos & TDEFL_LZ_DICT_SIZE_MASK] << (TDEFL_LZ_HASH_SHIFT * 2)) ^ (d.m_dict[(ins_pos + 1) & TDEFL_LZ_DICT_SIZE_MASK] << TDEFL_LZ_HASH_SHIFT) ^ c) & (TDEFL_LZ_HASH_SIZE - 1);
		                    d.m_next[ins_pos & TDEFL_LZ_DICT_SIZE_MASK] = d.m_hash[hash];
		                    d.m_hash[hash] = (mz_uint16)(ins_pos);
		                }
		            }
		        }
		        d.m_dict_size = MZ_MIN!(TDEFL_LZ_DICT_SIZE - d.m_lookahead_size, d.m_dict_size);
		        if ((flush == 0) && (d.m_lookahead_size < TDEFL_MAX_MATCH_LEN))
		            break;

		        /* Simple lazy/greedy parsing state machine. */
		        len_to_move = 1;
		        cur_match_dist = 0;
		        cur_match_len = d.m_saved_match_len != 0 ? d.m_saved_match_len : (TDEFL_MIN_MATCH_LEN - 1);
		        cur_pos = d.m_lookahead_pos & TDEFL_LZ_DICT_SIZE_MASK;
		        if ((d.m_flags & (.TDEFL_RLE_MATCHES | .TDEFL_FORCE_ALL_RAW_BLOCKS)) != 0)
		        {
		            if ((d.m_dict_size != 0) && ((d.m_flags & .TDEFL_FORCE_ALL_RAW_BLOCKS) == 0))
		            {
		                mz_uint8 c = d.m_dict[(cur_pos - 1) & TDEFL_LZ_DICT_SIZE_MASK];
		                cur_match_len = 0;
		                while (cur_match_len < d.m_lookahead_size)
		                {
		                    if (d.m_dict[cur_pos + cur_match_len] != c)
		                        break;
		                    cur_match_len++;
		                }
		                if (cur_match_len < TDEFL_MIN_MATCH_LEN)
		                    cur_match_len = 0;
		                else
		                    cur_match_dist = 1;
		            }
		        }
		        else
		        {
		            tdefl_find_match(d, d.m_lookahead_pos, d.m_dict_size, d.m_lookahead_size, &cur_match_dist, &cur_match_len);
		        }
		        if (((cur_match_len == TDEFL_MIN_MATCH_LEN) && (cur_match_dist >= 8U * 1024U)) || (cur_pos == cur_match_dist) || ((d.m_flags & .TDEFL_FILTER_MATCHES) != 0 && (cur_match_len <= 5)))
		        {
		            cur_match_dist = cur_match_len = 0;
		        }
		        if (d.m_saved_match_len != 0)
		        {
		            if (cur_match_len > d.m_saved_match_len)
		            {
		                tdefl_record_literal(d, (mz_uint8)d.m_saved_lit);
		                if (cur_match_len >= 128)
		                {
		                    tdefl_record_match(d, cur_match_len, cur_match_dist);
		                    d.m_saved_match_len = 0;
		                    len_to_move = cur_match_len;
		                }
		                else
		                {
		                    d.m_saved_lit = d.m_dict[cur_pos];
		                    d.m_saved_match_dist = cur_match_dist;
		                    d.m_saved_match_len = cur_match_len;
		                }
		            }
		            else
		            {
		                tdefl_record_match(d, d.m_saved_match_len, d.m_saved_match_dist);
		                len_to_move = d.m_saved_match_len - 1;
		                d.m_saved_match_len = 0;
		            }
		        }
		        else if (cur_match_dist == 0)
		            tdefl_record_literal(d, d.m_dict[MZ_MIN!(cur_pos, sizeof(decltype(d.m_dict)) - 1)]);
		        else if ((d.m_greedy_parsing != 0) || (d.m_flags & .TDEFL_RLE_MATCHES) != 0 || (cur_match_len >= 128))
		        {
		            tdefl_record_match(d, cur_match_len, cur_match_dist);
		            len_to_move = cur_match_len;
		        }
		        else
		        {
		            d.m_saved_lit = d.m_dict[MZ_MIN!(cur_pos, sizeof(decltype(d.m_dict)) - 1)];
		            d.m_saved_match_dist = cur_match_dist;
		            d.m_saved_match_len = cur_match_len;
		        }
		        /* Move the lookahead forward by len_to_move bytes. */
		        d.m_lookahead_pos += len_to_move;
		        Debug.Assert(d.m_lookahead_size >= len_to_move);
		        d.m_lookahead_size -= len_to_move;
		        d.m_dict_size = MZ_MIN!(d.m_dict_size + len_to_move, (mz_uint)TDEFL_LZ_DICT_SIZE);
		        /* Check if it's time to flush the current LZ codes to the internal output buffer. */
		        if ((d.m_pLZ_code_buf > &d.m_lz_code_buf[TDEFL_LZ_CODE_BUF_SIZE - 8]) ||
		            ((d.m_total_lz_bytes > 31 * 1024) && (((((mz_uint)(d.m_pLZ_code_buf - &d.m_lz_code_buf[0]) * 115) >> 7) >= d.m_total_lz_bytes) || (d.m_flags & .TDEFL_FORCE_ALL_RAW_BLOCKS) != 0)))
		        {
		            int n;
		            d.m_pSrc = pSrc;
		            d.m_src_buf_left = src_buf_left;
		            if ((n = tdefl_flush_block(d, 0)) != 0)
		                return (n < 0) ? false : true;
		        }
		    }

		    d.m_pSrc = pSrc;
		    d.m_src_buf_left = src_buf_left;
		    return true;
		}

		static tdefl_status tdefl_flush_output_buffer(tdefl_compressor *d)
		{
		    if (d.m_pIn_buf_size != null)
		    {
		        *d.m_pIn_buf_size = d.m_pSrc - (mz_uint8 *)d.m_pIn_buf;
		    }

		    if (d.m_pOut_buf_size != null)
		    {
		        size_t n = MZ_MIN!(*d.m_pOut_buf_size - d.m_out_buf_ofs, d.m_output_flush_remaining);
		        memcpy(((mz_uint8 *)d.m_pOut_buf) + d.m_out_buf_ofs, &d.m_output_buf[d.m_output_flush_ofs], n);
		        d.m_output_flush_ofs += (mz_uint)n;
		        d.m_output_flush_remaining -= (mz_uint)n;
		        d.m_out_buf_ofs += n;

		        *d.m_pOut_buf_size = d.m_out_buf_ofs;
		    }

		    return (d.m_finished && d.m_output_flush_remaining == 0) ? .TDEFL_STATUS_DONE : .TDEFL_STATUS_OKAY;
		}

		static tdefl_status tdefl_compress(tdefl_compressor *d, void *pIn_buf, size_t *pIn_buf_size, void *pOut_buf, size_t *pOut_buf_size, tdefl_flush flush)
		{
		    if (d == null)
		    {
		        if (pIn_buf_size != null)
		            *pIn_buf_size = 0;
		        if (pOut_buf_size != null)
		            *pOut_buf_size = 0;
		        return .TDEFL_STATUS_BAD_PARAM;
		    }

		    d.m_pIn_buf = pIn_buf;
		    d.m_pIn_buf_size = pIn_buf_size;
		    d.m_pOut_buf = pOut_buf;
		    d.m_pOut_buf_size = pOut_buf_size;
		    d.m_pSrc = (mz_uint8 *)(pIn_buf);
		    d.m_src_buf_left = pIn_buf_size != null ? *pIn_buf_size : 0;
		    d.m_out_buf_ofs = 0;
		    d.m_flush = flush;

		    if (((d.m_pPut_buf_func != null) == ((pOut_buf != null) || (pOut_buf_size != null))) || (d.m_prev_return_status != .TDEFL_STATUS_OKAY) ||
		        (d.m_wants_to_finish && (flush != .TDEFL_FINISH)) || (pIn_buf_size != null && *pIn_buf_size != 0 && pIn_buf == null) || (pOut_buf_size != null && *pOut_buf_size != 0 && pOut_buf == null))
		    {
		        if (pIn_buf_size != null)
		            *pIn_buf_size = 0;
		        if (pOut_buf_size != null)
		            *pOut_buf_size = 0;
		        return (d.m_prev_return_status = .TDEFL_STATUS_BAD_PARAM);
		    }
		    d.m_wants_to_finish |= (flush == .TDEFL_FINISH);

		    if ((d.m_output_flush_remaining != 0) || (d.m_finished))
		        return (d.m_prev_return_status = tdefl_flush_output_buffer(d));

#if MINIZ_USE_UNALIGNED_LOADS_AND_STORES && MINIZ_LITTLE_ENDIAN
		    if (((int32)(d.m_flags & .TDEFL_MAX_PROBES_MASK) == 1) &&
		        ((d.m_flags & .TDEFL_GREEDY_PARSING_FLAG) != 0) &&
		        ((d.m_flags & (.TDEFL_FILTER_MATCHES | .TDEFL_FORCE_ALL_RAW_BLOCKS | .TDEFL_RLE_MATCHES)) == 0))
		    {
		        if (!tdefl_compress_fast(d))
		            return d.m_prev_return_status;
		    }
		    else
#endif /* #if MINIZ_USE_UNALIGNED_LOADS_AND_STORES && MINIZ_LITTLE_ENDIAN */
		    {
		        if (!tdefl_compress_normal(d))
		            return d.m_prev_return_status;
		    }

		    if ((d.m_flags & (.TDEFL_WRITE_ZLIB_HEADER | .TDEFL_COMPUTE_ADLER32)) != 0 && (pIn_buf != null))
		        d.m_adler32 = (mz_uint32)mz_adler32(d.m_adler32, (mz_uint8 *)pIn_buf, d.m_pSrc - (mz_uint8 *)pIn_buf);

		    if ((flush != 0) && (d.m_lookahead_size == 0) && (d.m_src_buf_left == 0) && (d.m_output_flush_remaining == 0))
		    {
		        if (tdefl_flush_block(d, flush) < 0)
		            return d.m_prev_return_status;
		        d.m_finished = (flush == .TDEFL_FINISH);
		        if (flush == .TDEFL_FULL_FLUSH)
		        {
		            d.m_hash = default;
		            d.m_next = default;
		            d.m_dict_size = 0;
		        }
		    }

		    return (d.m_prev_return_status = tdefl_flush_output_buffer(d));
		}

		static tdefl_status tdefl_compress_buffer(tdefl_compressor *d, void *pIn_buf, size_t in_buf_size, tdefl_flush flush)
		{
			var in_buf_size;
		    Debug.Assert(d.m_pPut_buf_func != null);
		    return tdefl_compress(d, pIn_buf, &in_buf_size, null, null, flush);
		}

		static tdefl_status tdefl_init(tdefl_compressor *d, tdefl_put_buf_func_ptr pPut_buf_func, void *pPut_buf_user, tdefl_flags flags)
		{
		    d.m_pPut_buf_func = pPut_buf_func;
		    d.m_pPut_buf_user = pPut_buf_user;
		    d.m_flags = (flags);
		    d.m_max_probes[0] = 1 + (((uint32)flags & 0xFFF) + 2) / 3;
		    d.m_greedy_parsing = ((flags & .TDEFL_GREEDY_PARSING_FLAG) != 0) ? 1 : 0;
		    d.m_max_probes[1] = 1 + ((((uint32)flags & 0xFFF) >> 2) + 2) / 3;
		    if ((flags & .TDEFL_NONDETERMINISTIC_PARSING_FLAG) == 0)
		        d.m_hash = default;
		    d.m_lookahead_pos = d.m_lookahead_size = d.m_dict_size = d.m_total_lz_bytes = d.m_lz_code_buf_dict_pos = d.m_bits_in = 0;
		    d.m_output_flush_ofs = d.m_output_flush_remaining = d.m_block_index = d.m_bit_buffer = 0;
			d.m_finished = d.m_wants_to_finish = false;
		    d.m_pLZ_code_buf = &d.m_lz_code_buf[1];
		    d.m_pLZ_flags = &d.m_lz_code_buf[0];
		    d.m_num_flags_left = 8;
		    d.m_pOutput_buf = &d.m_output_buf[0];
		    d.m_pOutput_buf_end = &d.m_output_buf[0];
		    d.m_prev_return_status = .TDEFL_STATUS_OKAY;
		    d.m_saved_match_dist = d.m_saved_match_len = d.m_saved_lit = 0;
		    d.m_adler32 = 1;
		    d.m_pIn_buf = null;
		    d.m_pOut_buf = null;
		    d.m_pIn_buf_size = null;
		    d.m_pOut_buf_size = null;
		    d.m_flush = .TDEFL_NO_FLUSH;
		    d.m_pSrc = null;
		    d.m_src_buf_left = 0;
		    d.m_out_buf_ofs = 0;
		    if ((flags & .TDEFL_NONDETERMINISTIC_PARSING_FLAG) == 0)
		        d.m_dict = default;
		    memset(&d.m_huff_count[0][0], 0, sizeof(decltype(d.m_huff_count[0][0])) * TDEFL_MAX_HUFF_SYMBOLS_0);
		    memset(&d.m_huff_count[1][0], 0, sizeof(decltype(d.m_huff_count[1][0])) * TDEFL_MAX_HUFF_SYMBOLS_1);
		    return .TDEFL_STATUS_OKAY;
		}

		static tdefl_status tdefl_get_prev_return_status(tdefl_compressor *d)
		{
		    return d.m_prev_return_status;
		}

		static mz_uint32 tdefl_get_adler32(tdefl_compressor *d)
		{
		    return d.m_adler32;
		}

		static bool tdefl_compress_mem_to_output(void *pBuf, size_t buf_len, tdefl_put_buf_func_ptr pPut_buf_func, void *pPut_buf_user, tdefl_flags flags)
		{
		    tdefl_compressor *pComp;
		    bool succeeded;
		    if (((buf_len != 0) && (pBuf == null)) || (pPut_buf_func == 0))
		        return false;
		    pComp = (tdefl_compressor *)MZ_MALLOC(sizeof(tdefl_compressor));
		    if (pComp == null)
		        return false;
		    succeeded = (tdefl_init(pComp, pPut_buf_func, pPut_buf_user, flags) == .TDEFL_STATUS_OKAY);
		    succeeded = succeeded && (tdefl_compress_buffer(pComp, pBuf, buf_len, .TDEFL_FINISH) == .TDEFL_STATUS_DONE);
		    MZ_FREE(pComp);
		    return succeeded;
		}

		struct tdefl_output_buffer
		{
		    public size_t m_size, m_capacity;
		    public mz_uint8 *m_pBuf;
		    public bool m_expandable;
		}

		static bool tdefl_output_buffer_putter(void *pBuf, int len, void *pUser)
		{
		    tdefl_output_buffer *p = (tdefl_output_buffer *)pUser;
		    size_t new_size = p.m_size + len;
		    if (new_size > p.m_capacity)
		    {
		        size_t new_capacity = p.m_capacity;
		        mz_uint8 *pNew_buf;
		        if (!p.m_expandable)
		            return false;
		        repeat
		        {
		            new_capacity = MZ_MAX!(128, new_capacity << 1);
		        } while (new_size > new_capacity);
		        pNew_buf = (mz_uint8 *)MZ_REALLOC(&p.m_pBuf[0], new_capacity);
		        if (pNew_buf == null)
		            return false;
		        p.m_pBuf = pNew_buf;
		        p.m_capacity = new_capacity;
		    }
		    memcpy((mz_uint8 *)p.m_pBuf + p.m_size, pBuf, len);
		    p.m_size = new_size;
		    return true;
		}

		static void *tdefl_compress_mem_to_heap(void *pSrc_buf, size_t src_buf_len, size_t *pOut_len, tdefl_flags flags)
		{
		    tdefl_output_buffer out_buf = default;
		    if (pOut_len == null)
		        return null;
		    else
		        *pOut_len = 0;
		    out_buf.m_expandable = true;
		    if (!tdefl_compress_mem_to_output(pSrc_buf, src_buf_len, => tdefl_output_buffer_putter, &out_buf, flags))
		        return null;
		    *pOut_len = out_buf.m_size;
		    return out_buf.m_pBuf;
		}

		static size_t tdefl_compress_mem_to_mem(void *pOut_buf, size_t out_buf_len, void *pSrc_buf, size_t src_buf_len, tdefl_flags flags)
		{
		    tdefl_output_buffer out_buf = default;
		    if (pOut_buf == null)
		        return 0;
		    out_buf.m_pBuf = (mz_uint8 *)pOut_buf;
		    out_buf.m_capacity = out_buf_len;
		    if (!tdefl_compress_mem_to_output(pSrc_buf, src_buf_len, => tdefl_output_buffer_putter, &out_buf, flags))
		        return 0;
		    return out_buf.m_size;
		}

		static mz_uint[11] s_tdefl_num_probes = .( 0, 1, 6, 32, 16, 32, 128, 256, 512, 768, 1500 );

		/* level may actually range from [0,10] (10 is a "hidden" max level, where we want a bit more compression and it's fine if throughput to fall off a cliff on some files). */
		static tdefl_flags tdefl_create_comp_flags_from_zip_params(CompressionLevel level, int32 window_bits, CompressionStrategy strategy)
		{
		    tdefl_flags comp_flags = (.)(s_tdefl_num_probes[(level >= 0) ? MZ_MIN!(10, level.Underlying) : (int32)CompressionLevel.DEFAULT_LEVEL] | ((level.Underlying <= 3) ? (int32)tdefl_flags.TDEFL_GREEDY_PARSING_FLAG : 0));
		    if (window_bits > 0)
		        comp_flags |= .TDEFL_WRITE_ZLIB_HEADER;

		    if (level == 0)
		        comp_flags |= .TDEFL_FORCE_ALL_RAW_BLOCKS;
		    else if (strategy == .FILTERED)
		        comp_flags |= .TDEFL_FILTER_MATCHES;
		    else if (strategy == .HUFFMAN_ONLY)
		        comp_flags &= ~.TDEFL_MAX_PROBES_MASK;
		    else if (strategy == .FIXED)
		        comp_flags |= .TDEFL_FORCE_ALL_STATIC_BLOCKS;
		    else if (strategy == .RLE)
		        comp_flags |= .TDEFL_RLE_MATCHES;

		    return comp_flags;
		}

		/* Simple PNG writer function by Alex Evans, 2011. Released into the public domain: https://gist.github.com/908299, more context at
		 http://altdevblogaday.org/2011/04/06/a-smaller-jpg-encoder/.
		 This is actually a modification of Alex's original code so PNG files generated by this function pass pngcheck. */
		static void *tdefl_write_image_to_png_file_in_memory_ex(void *pImage, int w, int h, int num_chans, size_t *pLen_out, mz_uint level, bool flip)
		{
		    /* Using a local copy of this array here in case MINIZ_NO_ZLIB_APIS was defined. */
		    tdefl_compressor *pComp = (tdefl_compressor *)MZ_MALLOC(sizeof(tdefl_compressor));
		    tdefl_output_buffer out_buf;
		    int i, bpl = w * num_chans, y, z;
		    mz_uint32 c;
		    *pLen_out = 0;
		    if (pComp == null)
		        return null;
		    out_buf = default;
		    out_buf.m_expandable = true;
		    out_buf.m_capacity = 57 + MZ_MAX!(64, (1 + bpl) * h);
		    if (null == (out_buf.m_pBuf = (mz_uint8 *)MZ_MALLOC(out_buf.m_capacity)))
		    {
		        MZ_FREE(pComp);
		        return null;
		    }
		    /* write dummy header */
		    for (z = 41; z != 0; --z)
		        tdefl_output_buffer_putter(&z, 1, &out_buf);
		    /* compress image data */
		    tdefl_init(pComp, => tdefl_output_buffer_putter, &out_buf, (.)s_tdefl_num_probes[MZ_MIN!(10, level)] | .TDEFL_WRITE_ZLIB_HEADER);
		    for (y = 0; y < h; ++y)
		    {
		        tdefl_compress_buffer(pComp, &z, 1, .TDEFL_NO_FLUSH);
		        tdefl_compress_buffer(pComp, (mz_uint8 *)pImage + (flip ? (h - 1 - y) : y) * bpl, bpl, .TDEFL_NO_FLUSH);
		    }
		    if (tdefl_compress_buffer(pComp, null, 0, .TDEFL_FINISH) != .TDEFL_STATUS_DONE)
		    {
		        MZ_FREE(pComp);
		        MZ_FREE(out_buf.m_pBuf);
		        return null;
		    }
		    /* write real header */
		    *pLen_out = out_buf.m_size - 41;
		    {
		        const mz_uint8[?] chans = .( 0x00, 0x00, 0x04, 0x02, 0x06 );
		        mz_uint8[41] pnghdr = .( 0x89, 0x50, 0x4e, 0x47, 0x0d,
		                                0x0a, 0x1a, 0x0a, 0x00, 0x00,
		                                0x00, 0x0d, 0x49, 0x48, 0x44,
		                                0x52, 0x00, 0x00, 0x00, 0x00,
		                                0x00, 0x00, 0x00, 0x00, 0x08,
		                                0x00, 0x00, 0x00, 0x00, 0x00,
		                                0x00, 0x00, 0x00, 0x00, 0x00,
		                                0x00, 0x00, 0x49, 0x44, 0x41,
		                                0x54 );
		        pnghdr[18] = (mz_uint8)(w >> 8);
		        pnghdr[19] = (mz_uint8)w;
		        pnghdr[22] = (mz_uint8)(h >> 8);
		        pnghdr[23] = (mz_uint8)h;
		        pnghdr[25] = chans[num_chans];
		        pnghdr[33] = (mz_uint8)(*pLen_out >> 24);
		        pnghdr[34] = (mz_uint8)(*pLen_out >> 16);
		        pnghdr[35] = (mz_uint8)(*pLen_out >> 8);
		        pnghdr[36] = (mz_uint8)*pLen_out;
		        c = (mz_uint32)mz_crc32(MZ_CRC32_INIT, &pnghdr[0] + 12, 17);
		        for (i = 0; i < 4; ++i, c <<= 8)
		            ((mz_uint8 *)(&pnghdr[0] + 29))[i] = (mz_uint8)(c >> 24);
		        memcpy(out_buf.m_pBuf, &pnghdr[0], 41);
		    }
		    /* write footer (IDAT CRC-32, followed by IEND chunk) */
		    if (!tdefl_output_buffer_putter((char8*)"\0\0\0\0\0\0\0\0\x49\x45\x4e\x44\xae\x42\x60\x82", 16, &out_buf))
		    {
		        *pLen_out = 0;
		        MZ_FREE(pComp);
		        MZ_FREE(out_buf.m_pBuf);
		        return null;
		    }
		    c = (mz_uint32)mz_crc32(MZ_CRC32_INIT, out_buf.m_pBuf + 41 - 4, *pLen_out + 4);
		    for (i = 0; i < 4; ++i, c <<= 8)
		        (out_buf.m_pBuf + out_buf.m_size - 16)[i] = (mz_uint8)(c >> 24);
		    /* compute final size of file, grab compressed data buffer and return */
		    *pLen_out += 57;
		    MZ_FREE(pComp);
		    return out_buf.m_pBuf;
		}
		static void *tdefl_write_image_to_png_file_in_memory(void *pImage, int w, int h, int num_chans, size_t *pLen_out)
		{
		    /* Level 6 corresponds to TDEFL_DEFAULT_MAX_PROBES or MZ_DEFAULT_LEVEL (but we can't depend on MZ_DEFAULT_LEVEL being available in case the zlib API's where #defined out) */
		    return tdefl_write_image_to_png_file_in_memory_ex(pImage, w, h, num_chans, pLen_out, 6, false);
		}

/*//#ifndef MINIZ_NO_MALLOC
		/* Allocate the tdefl_compressor and tinfl_decompressor structures in C so that */
		/* non-C language bindings to tdefL_ and tinfl_ API don't need to worry about */
		/* structure size and allocation mechanism. */
		static tdefl_compressor *tdefl_compressor_alloc()
		{
		    return (tdefl_compressor *)MZ_MALLOC(sizeof(tdefl_compressor));
		}

		static void tdefl_compressor_free(tdefl_compressor *pComp)
		{
		    MZ_FREE(pComp);
		}*/

		// miniz_tinfl.c

		/* ------------------- Low-level Decompression (completely independent from all compression API's) */

		static int32[31] s_length_base = .( 3, 4, 5, 6, 7, 8, 9, 10, 11, 13, 15, 17, 19, 23, 27, 31, 35, 43, 51, 59, 67, 83, 99, 115, 131, 163, 195, 227, 258, 0, 0 );
		static int32[31] s_length_extra = .( 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5, 0, 0, 0 );
		static int32[32] s_dist_base = .( 1, 2, 3, 4, 5, 7, 9, 13, 17, 25, 33, 49, 65, 97, 129, 193, 257, 385, 513, 769, 1025, 1537, 2049, 3073, 4097, 6145, 8193, 12289, 16385, 24577, 0, 0 );
		static int32[32] s_dist_extra = .( 0, 0, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9, 10, 10, 11, 11, 12, 12, 13, 13, /*zero the rest*/);
		static mz_uint8[19] s_length_dezigzag = .( 16, 17, 18, 0, 8, 7, 9, 6, 10, 5, 11, 4, 12, 3, 13, 2, 14, 1, 15 );
		static int32[3] s_min_table_sizes = .( 257, 1, 4 );

		static tinfl_status tinfl_decompress(tinfl_decompressor *r, mz_uint8 *pIn_buf_next, size_t *pIn_buf_size, mz_uint8 *pOut_buf_start, mz_uint8 *pOut_buf_next, size_t *pOut_buf_size, tinfl_flags decomp_flags)
		{
		    tinfl_status status = .TINFL_STATUS_FAILED;
		    mz_uint32 num_bits, dist, counter, num_extra;
		    tinfl_bit_buf_t bit_buf;
		    mz_uint8* pIn_buf_cur = pIn_buf_next, pIn_buf_end = pIn_buf_next + *pIn_buf_size;
		    mz_uint8* pOut_buf_cur = pOut_buf_next, pOut_buf_end = pOut_buf_next + *pOut_buf_size;
		    size_t out_buf_size_mask = (decomp_flags & .TINFL_FLAG_USING_NON_WRAPPING_OUTPUT_BUF) != 0 ? (size_t)-1 : ((pOut_buf_next - pOut_buf_start) + *pOut_buf_size) - 1, dist_from_out_buf_start;

		    /* Ensure the output buffer's size is a power of 2, unless the output buffer is large enough to hold the entire output file (in which case it doesn't matter). */
		    if (((out_buf_size_mask + 1) & out_buf_size_mask) != 0 || (pOut_buf_next < pOut_buf_start))
		    {
		        *pIn_buf_size = *pOut_buf_size = 0;
		        return .TINFL_STATUS_BAD_PARAM;
		    }

		    num_bits = r.m_num_bits;
		    bit_buf = r.m_bit_buf;
		    dist = r.m_dist;
		    counter = r.m_counter;
		    num_extra = r.m_num_extra;
		    dist_from_out_buf_start = r.m_dist_from_out_buf_start;

			mixin GetByte(var c)
			{
				if (pIn_buf_cur >= pIn_buf_end)
				{
					if (decomp_flags.HasFlag(.TINFL_FLAG_HAS_MORE_INPUT))
					{
						DoResult!((decomp_flags & .TINFL_FLAG_HAS_MORE_INPUT) != 0 ? tinfl_status.TINFL_STATUS_NEEDS_MORE_INPUT : tinfl_status.TINFL_STATUS_FAILED_CANNOT_MAKE_PROGRESS);
					}
					/*else
						c = 0;*/
				}
				//else
				c = *pIn_buf_cur++;
			}

			mixin NeedBits(var n)
			{
				repeat
				{
					mz_uint c = ?;
					GetByte!(c);
					bit_buf |= (((tinfl_bit_buf_t)c) << num_bits);
					num_bits += 8;
				}
				while (num_bits < (mz_uint)(n));
			}

			mixin GetBits<T>(T b, var n) where T : var
			{
				if (num_bits < (mz_uint)(n))
				{
					NeedBits!(n);
				}
				b = (T)(bit_buf & ((1 << (mz_uint)(n)) - 1));
				bit_buf >>= (n);
				num_bits -= (n);
			}

			mixin SkipBits(var n)
			{
				if (num_bits < (mz_uint)(n))
				{
					NeedBits!(n);
				}
				bit_buf >>= (n);
				num_bits -= (n);
			}

			mixin HuffDecode(var sym, var pHuff)
			{
				int32 temp; mz_uint code_len, c = ?;
				if (num_bits < 15)
				{
					if ((pIn_buf_end - pIn_buf_cur) < 2)
					{
						repeat
						{
							temp = (int32)pHuff.m_look_up[bit_buf & (TINFL_FAST_LOOKUP_SIZE - 1)];
							if (temp >= 0)
							{
								code_len = (.)(temp >> 9);
								if ((code_len != 0) && (num_bits >= code_len))
									break;
							}
							else if (num_bits > TINFL_FAST_LOOKUP_BITS)
							{
								code_len = TINFL_FAST_LOOKUP_BITS;
								repeat
								{
									temp = (uint16)pHuff.m_tree[~temp + (int32)((bit_buf >> code_len++) & 1)];
								}
								while ((temp < 0) && (num_bits >= (code_len + 1)));
								if (temp >= 0)
									break;
							}
							GetByte!(c);
							bit_buf |= (((tinfl_bit_buf_t)c) << num_bits); num_bits += 8;
						}
						while (num_bits < 15);
					}
					else
					{
						bit_buf |= (((tinfl_bit_buf_t)pIn_buf_cur[0]) << num_bits) | (((tinfl_bit_buf_t)pIn_buf_cur[1]) << (num_bits + 8));
						pIn_buf_cur += 2;
						num_bits += 16;
					}
				}
				if ((temp = pHuff.m_look_up[bit_buf & (TINFL_FAST_LOOKUP_SIZE - 1)]) >= 0)
				{
					code_len = (.)(temp >> 9);
					temp &= 511;
				}
				else
				{
					code_len = TINFL_FAST_LOOKUP_BITS;
					repeat
					{
						temp = pHuff.m_tree[~temp + (int32)((bit_buf >> code_len++) & 1)];
					}
					while (temp < 0);
				}
				sym = (.)temp;
				bit_buf >>= code_len;
				num_bits -= code_len;
			}

			mixin DoResult(tinfl_status outResult)
			{
				status = outResult;
				break OuterLoop;
			}

			OuterLoop:while(true)
			{
				StateSwitch:switch(r.m_state)
				{
				case 0:
					bit_buf = num_bits = dist = counter = num_extra = r.m_zhdr0 = r.m_zhdr1 = 0;
					r.m_z_adler32 = r.m_check_adler32 = 1;
					if ((decomp_flags & .TINFL_FLAG_PARSE_ZLIB_HEADER) != 0)
					{
						GetByte!(r.m_zhdr0);
						r.m_state = 1;
					}
					else
					{
						r.m_state = 3;
						break;
					}
					fallthrough;
				case 1:
					GetByte!(r.m_zhdr1);
					r.m_state = 2;
					fallthrough;
				case 2:
					counter = (((r.m_zhdr0 * 256 + r.m_zhdr1) % 31 != 0) || (r.m_zhdr1 & 32) != 0 || ((r.m_zhdr0 & 15) != 8)) ? 1 : 0;
					if ((decomp_flags & .TINFL_FLAG_USING_NON_WRAPPING_OUTPUT_BUF) == 0)
					    counter |= (((1U << (8U + (r.m_zhdr0 >> 4))) > 32768U) || ((out_buf_size_mask + 1) < (size_t)(1U << (8U + (r.m_zhdr0 >> 4))))) ? 1 : 0;
					if (counter != 0)
					    DoResult!(tinfl_status.TINFL_STATUS_FAILED);
					r.m_state = 3;
					fallthrough;
				case 3: // do
					GetBits!(r.m_final, 3);
					r.m_type = r.m_final >> 1;
					if (r.m_type == 0)
						r.m_state = 5;
					else if (r.m_type == 3)
						r.m_state = 9;
					else r.m_state = 10;

				case 5: // if (r.m_type == 0)
					SkipBits!(num_bits & 7);
					counter = 0;
					r.m_state = 6;
				case 6: // header loop
					if (num_bits != 0)
						GetBits!(r.m_raw_header[counter], 8);
					else GetByte!(r.m_raw_header[counter]);
					if (++counter < 4)
						break;

					if ((counter = (r.m_raw_header[0] | ((mz_uint)r.m_raw_header[1] << 8))) != (mz_uint)(0xFFFF ^ (r.m_raw_header[2] | ((mz_uint)r.m_raw_header[3] << 8))))
						DoResult!(tinfl_status.TINFL_STATUS_FAILED);
					r.m_state = 7;
					fallthrough;
				case 7:
					while ((counter > 0) && (num_bits != 0))
					{
						if (pOut_buf_cur >= pOut_buf_end)
							DoResult!(tinfl_status.TINFL_STATUS_HAS_MORE_OUTPUT);
						GetBits!(dist, 8);
						*pOut_buf_cur++ = (mz_uint8)dist;
						counter--;
					}
					while (counter != 0)
					{
						size_t n;
						if (pOut_buf_cur >= pOut_buf_end)
						{
							//r.m_state = 9;
							DoResult!(tinfl_status.TINFL_STATUS_HAS_MORE_OUTPUT);
						}
						if (pIn_buf_cur >= pIn_buf_end)
						{
							DoResult!((decomp_flags & .TINFL_FLAG_HAS_MORE_INPUT) != 0 ? tinfl_status.TINFL_STATUS_NEEDS_MORE_INPUT : tinfl_status.TINFL_STATUS_FAILED_CANNOT_MAKE_PROGRESS);
						}
						n = MZ_MIN!(MZ_MIN!((size_t)(pOut_buf_end - pOut_buf_cur), (size_t)(pIn_buf_end - pIn_buf_cur)), counter);
						memcpy(pOut_buf_cur, pIn_buf_cur, n);
						pIn_buf_cur += n;
						pOut_buf_cur += n;
						counter -= (mz_uint)n;
					}

					r.m_state = 30; // jump to end of for(;;)
				case 9: // else if (r.m_type == 3)
					//r.m_state = 10;
					DoResult!(tinfl_status.TINFL_STATUS_FAILED);
				case 10: // else r.m_state = 10;
					if (r.m_type == 1)
					{
					    mz_uint8 *p = &r.m_tables[0].m_code_size[0];
					    mz_uint i;
					    r.m_table_sizes[0] = 288;
					    r.m_table_sizes[1] = 32;
					    memset(&r.m_tables[1].m_code_size[0], 5, 32);
					    for (i = 0; i <= 143; ++i)
					        *p++ = 8;
					    for (; i <= 255; ++i)
					        *p++ = 9;
					    for (; i <= 279; ++i)
					        *p++ = 7;
					    for (; i <= 287; ++i)
					        *p++ = 8;

						r.m_state = 13; // jump to beginning of loop - skip else below
						break;
					}
					else
					{
						counter = 0;
						r.m_state = 11;
					}
					fallthrough;
				case 11:
					if (counter == 2)
						GetBits!(r.m_table_sizes[counter], 4);
					else GetBits!(r.m_table_sizes[counter], 5);
					r.m_table_sizes[counter] += (.)s_min_table_sizes[counter];
					if (++counter < 3)
						break;
					r.m_tables[2].m_code_size = default;
					counter = 0;
					r.m_state = 12;
					fallthrough;
				case 12:
					mz_uint s = ?;
					GetBits!(s, 3);
					r.m_tables[2].m_code_size[s_length_dezigzag[counter]] = (mz_uint8)s;
					if (++counter < r.m_table_sizes[2])
						break;
					r.m_table_sizes[2] = 19;
					r.m_state = 13;
					fallthrough;
				case 13: // for (; (int)r.m_type >= 0; r.m_type--)
					while ((int32)r.m_type >= 0)
					{
						int tree_next, tree_cur;
						tinfl_huff_table *pTable;
						mz_uint i, j, used_syms, total, sym_index;
						mz_uint[17] next_code;
						mz_uint[16] total_syms = default;
						pTable = &r.m_tables[r.m_type];
						pTable.m_look_up = default;
						pTable.m_tree = default;
						for (i = 0; i < r.m_table_sizes[r.m_type]; ++i)
						    total_syms[pTable.m_code_size[i]]++;
						used_syms = 0;
						total = 0;
						next_code[0] = next_code[1] = 0;
						for (i = 1; i <= 15; ++i)
						{
						    used_syms += total_syms[i];
						    next_code[i + 1] = (total = ((total + total_syms[i]) << 1));
						}
						if ((65536 != total) && (used_syms > 1))
						{
						    DoResult!(tinfl_status.TINFL_STATUS_FAILED);
						}
						for (tree_next = -1, sym_index = 0; sym_index < r.m_table_sizes[r.m_type]; ++sym_index)
						{
						    mz_uint rev_code = 0;
							mz_uint l;
							mz_uint cur_code;
							mz_uint code_size = pTable.m_code_size[sym_index];
						    if (code_size == 0)
						        continue;
						    cur_code = next_code[code_size]++;
						    for (l = code_size; l > 0; l--, cur_code >>= 1)
						        rev_code = (rev_code << 1) | (cur_code & 1);
						    if (code_size <= TINFL_FAST_LOOKUP_BITS)
						    {
						        mz_int16 k = (mz_int16)((code_size << 9) | sym_index);
						        while (rev_code < TINFL_FAST_LOOKUP_SIZE)
						        {
						            pTable.m_look_up[rev_code] = k;
						            rev_code += (1 << code_size);
						        }
						        continue;
						    }
						    if (0 == (tree_cur = pTable.m_look_up[rev_code & (TINFL_FAST_LOOKUP_SIZE - 1)]))
						    {
						        pTable.m_look_up[rev_code & (TINFL_FAST_LOOKUP_SIZE - 1)] = (mz_int16)tree_next;
						        tree_cur = tree_next;
						        tree_next -= 2;
						    }
						    rev_code >>= (TINFL_FAST_LOOKUP_BITS - 1);
						    for (j = code_size; j > (TINFL_FAST_LOOKUP_BITS + 1); j--)
						    {
						        tree_cur -= ((rev_code >>= 1) & 1);
						        if (pTable.m_tree[-tree_cur - 1] == 0)
						        {
						            pTable.m_tree[-tree_cur - 1] = (mz_int16)tree_next;
						            tree_cur = tree_next;
						            tree_next -= 2;
						        }
						        else
						            tree_cur = pTable.m_tree[-tree_cur - 1];
						    }
						    tree_cur -= ((rev_code >>= 1) & 1);
						    pTable.m_tree[-tree_cur - 1] = (mz_int16)sym_index;
						}
						if (r.m_type == 2)
						{
						    dist = 0;
							counter = 0;
							r.m_state = 14;
							break StateSwitch;
						}
						else
						{
							r.m_type--;
						}
					}

					r.m_state = 22; // jump to for(;;)
				case 14: // if (r.m_type == 2)
					do
					{
						mz_uint s = ?;
						HuffDecode!(dist, &r.m_tables[2]);
						if (dist < 16)
						{
						    r.m_len_codes[counter++] = (mz_uint8)dist;
							break;
						}
						else if ((dist == 16) && (counter == 0))
						{
						    DoResult!(tinfl_status.TINFL_STATUS_FAILED);
						}

						switch (dist - 16) // @change this seems really weird
						{
						case 0:
							GetBits!(s, 2);
							s += 3;
						case 1:
							GetBits!(s, 3);
							s += 3;
						case 2:
							GetBits!(s, 7);
							s += 11; // @change was 13 before, apparently needs to be 11?
						}

						memset(&r.m_len_codes[counter], (dist == 16) ? r.m_len_codes[counter - 1] : 0, s);
						counter += s;
					}

					if (counter < (r.m_table_sizes[0] + r.m_table_sizes[1]))
						break;

					if ((r.m_table_sizes[0] + r.m_table_sizes[1]) != counter)
					{
					    DoResult!(tinfl_status.TINFL_STATUS_FAILED);
					}
					memcpy(&r.m_tables[0].m_code_size, &r.m_len_codes, r.m_table_sizes[0]);
					memcpy(&r.m_tables[1].m_code_size, &r.m_len_codes[r.m_table_sizes[0]], r.m_table_sizes[1]);

					r.m_type--;
					r.m_state = 13; // Return to loop

				case 22: // for (;;) (both outer and inner)
					if (((pIn_buf_end - pIn_buf_cur) < 4) || ((pOut_buf_end - pOut_buf_cur) < 2))
                    {
                        HuffDecode!(counter, &r.m_tables[0]);
                        if (counter >= 256)
						{
							r.m_state = 24; // end of inner for
                            break;
						}

						r.m_state = 23;
                        break;
                    }
                    else
                    {
                        int32 sym2;
                        mz_uint code_len;
#if TINFL_USE_64BIT_BITBUF
                        if (num_bits < 30)
                        {
                            bit_buf |= (((tinfl_bit_buf_t)MZ_READ_LE32(pIn_buf_cur)) << num_bits);
                            pIn_buf_cur += 4;
                            num_bits += 32;
                        }
#else
                        if (num_bits < 15)
                        {
                            bit_buf |= (((tinfl_bit_buf_t)MZ_READ_LE16(pIn_buf_cur)) << num_bits);
                            pIn_buf_cur += 2;
                            num_bits += 16;
                        }
#endif
                        if ((sym2 = (int32)r.m_tables[0].m_look_up[bit_buf & (TINFL_FAST_LOOKUP_SIZE - 1)]) >= 0)
                            code_len = (.)sym2 >> 9;
                        else
                        {
                            code_len = TINFL_FAST_LOOKUP_BITS;
                            repeat
                            {
                                sym2 = r.m_tables[0].m_tree[~sym2 + (int32)((bit_buf >> code_len++) & 1)];
                            } while (sym2 < 0);
                        }
                        counter = (.)sym2;
                        bit_buf >>= code_len;
                        num_bits -= code_len;
                        if ((counter & 256) != 0)
                        {
							r.m_state = 24; // End of inner loop
							break;
						}    

#if !TINFL_USE_64BIT_BITBUF
                        if (num_bits < 15)
                        {
                            bit_buf |= (((tinfl_bit_buf_t)MZ_READ_LE16(pIn_buf_cur)) << num_bits);
                            pIn_buf_cur += 2;
                            num_bits += 16;
                        }
#endif
                        if ((sym2 = r.m_tables[0].m_look_up[bit_buf & (TINFL_FAST_LOOKUP_SIZE - 1)]) >= 0)
                            code_len = (.)sym2 >> 9;
                        else
                        {
                            code_len = TINFL_FAST_LOOKUP_BITS;
                            repeat
                            {
                                sym2 = r.m_tables[0].m_tree[~sym2 + (int32)((bit_buf >> code_len++) & 1)];
                            } while (sym2 < 0);
                        }
                        bit_buf >>= code_len;
                        num_bits -= code_len;

                        pOut_buf_cur[0] = (mz_uint8)counter;
                        if ((sym2 & 256) != 0)
                        {
                            pOut_buf_cur++;
                            counter = (.)sym2;

							r.m_state = 24; // End of inner loop
                            break;
                        }
                        pOut_buf_cur[1] = (mz_uint8)sym2;
                        pOut_buf_cur += 2;

						// Repeat inner loop
					}
				case 23:
					if (pOut_buf_cur >= pOut_buf_end)
					{
					    DoResult!(tinfl_status.TINFL_STATUS_HAS_MORE_OUTPUT);
					}
					*pOut_buf_cur++ = (mz_uint8)counter;

					r.m_state = 22; // Repeat inner loop
				case 24: // Outer for, at end of inner loop
					if ((counter &= 511) == 256)
					{
						r.m_state = 30; // End of outer for
					    break;
					}

					num_extra = (.)s_length_extra[counter - 257]; // @change casts, some above, too
					counter = (.)s_length_base[counter - 257];

					if (num_extra != 0)
						r.m_state = 25;
					else
					{
						r.m_state = 26;
						break;
					}
					fallthrough;
				case 25:
					mz_uint extra_bits;
					GetBits!(extra_bits, num_extra);
					counter += extra_bits;
					r.m_state = 26;
					fallthrough;
				case 26:
					HuffDecode!(dist, &r.m_tables[1]);
					num_extra = (.)s_dist_extra[dist];
					dist = (.)s_dist_base[dist];

					if (num_extra != 0)
						r.m_state = 27;
					else
					{
						r.m_state = 28;
						break;
					}
					fallthrough;
				case 27:
					mz_uint extra_bits;
					GetBits!(extra_bits, num_extra);
					dist += extra_bits;
					r.m_state = 28;
					fallthrough;
				case 28:
					dist_from_out_buf_start = pOut_buf_cur - pOut_buf_start;
					if ((dist == 0 || dist > dist_from_out_buf_start || dist_from_out_buf_start == 0) && (decomp_flags & .TINFL_FLAG_USING_NON_WRAPPING_OUTPUT_BUF) != 0)
					{
					    DoResult!(tinfl_status.TINFL_STATUS_FAILED);
					}

					uint8* pSrc = pOut_buf_start + ((dist_from_out_buf_start - dist) & out_buf_size_mask);

					if ((MZ_MAX!(pOut_buf_cur, pSrc) + counter) > pOut_buf_end)
	                {
	                    r.m_state = 29;
						break;
	                }
#if MINIZ_USE_UNALIGNED_LOADS_AND_STORES
	                else if ((counter >= 9) && (counter <= dist))
	                {
	                    mz_uint8 *pSrc_end = pSrc + (counter & ~7);
	                    repeat
	                    {
#if MINIZ_UNALIGNED_USE_MEMCPY
							memcpy(pOut_buf_cur, pSrc, sizeof(mz_uint32)*2);
#else
	                        ((mz_uint32*)pOut_buf_cur)[0] = ((mz_uint32*)pSrc)[0];
	                        ((mz_uint32*)pOut_buf_cur)[1] = ((mz_uint32*)pSrc)[1];
#endif
	                        pOut_buf_cur += 8;
	                    } while ((pSrc += 8) < pSrc_end);
	                    if ((counter &= 7) < 3)
	                    {
	                        if (counter != 0)
	                        {
	                            pOut_buf_cur[0] = pSrc[0];
	                            if (counter > 1)
	                                pOut_buf_cur[1] = pSrc[1];
	                            pOut_buf_cur += counter;
	                        }

							r.m_state = 22; // "continue;" back to start of outer loop
	                        break;
	                    }
	                }
#endif
	                while((int32)counter>2)
	                {
	                    pOut_buf_cur[0] = pSrc[0];
	                    pOut_buf_cur[1] = pSrc[1];
	                    pOut_buf_cur[2] = pSrc[2];
	                    pOut_buf_cur += 3;
	                    pSrc += 3;
						counter -= 3;
	                }
	                if ((int32)counter > 0)
	                {
	                    pOut_buf_cur[0] = pSrc[0];
	                    if ((int32)counter > 1)
	                        pOut_buf_cur[1] = pSrc[1];
	                    pOut_buf_cur += counter;
	                }

					// back to start of outer for
					r.m_state = 22;

				case 29:
					if (counter <= 0)
					{
						// back to start of outer loop (continue;)
						r.m_state = 22;
						break;
					}

					if (pOut_buf_cur >= pOut_buf_end)
					{
					    DoResult!(tinfl_status.TINFL_STATUS_HAS_MORE_OUTPUT);
					}
					*pOut_buf_cur++ = pOut_buf_start[(dist_from_out_buf_start++ - dist) & out_buf_size_mask];
					counter--;

				case 30: // Outer while condition
					if ((r.m_final & 1) == 0)
					{
						r.m_state = 3; // back to start of decode loop
						break;
					}

					r.m_state = 31;
					fallthrough;
				case 31:
					/* Ensure byte alignment and put back any bytes from the bitbuf if we've looked ahead too far on gzip, or other Deflate streams followed by arbitrary data. */
					/* I'm being super conservative here. A number of simplifications can be made to the byte alignment part, and the Adler32 check shouldn't ever need to worry about reading from the bitbuf now. */
					SkipBits!(num_bits & 7);
					while ((pIn_buf_cur > pIn_buf_next) && (num_bits >= 8))
					{
					    --pIn_buf_cur;
					    num_bits -= 8;
					}
					bit_buf &= (tinfl_bit_buf_t)((((mz_uint64)1) << num_bits) - (mz_uint64)1);
					Debug.Assert(num_bits == 0); /* if this assert fires then we've read beyond the end of non-deflate/zlib streams with following data (such as gzip streams). */

					if ((decomp_flags & .TINFL_FLAG_PARSE_ZLIB_HEADER) != 0)
					{
					    r.m_state = 32;
						counter = 0;
					}
					else
					{
						r.m_state = 33;
						break;
					}

					fallthrough;
				case 32:
					mz_uint s;
					if (num_bits != 0)
					    GetBits!(s, 8);
					else
					    GetByte!(s);
					r.m_z_adler32 = (r.m_z_adler32 << 8) | s;
					if (++counter < 4)
						break;

					r.m_state = 33;
					fallthrough;
				case 33:
					DoResult!(tinfl_status.TINFL_STATUS_DONE);
				}
			}

		    /* As long as we aren't telling the caller that we NEED more input to make forward progress: */
		    /* Put back any bytes from the bitbuf in case we've looked ahead too far on gzip, or other Deflate streams followed by arbitrary data. */
		    /* We need to be very careful here to NOT push back any bytes we definitely know we need to make forward progress, though, or we'll lock the caller up into an inf loop. */
		    if ((status != .TINFL_STATUS_NEEDS_MORE_INPUT) && (status != .TINFL_STATUS_FAILED_CANNOT_MAKE_PROGRESS))
		    {
		        while ((pIn_buf_cur > pIn_buf_next) && (num_bits >= 8))
		        {
		            --pIn_buf_cur;
		            num_bits -= 8;
		        }
		    }
		    r.m_num_bits = num_bits;
		    r.m_bit_buf = bit_buf & (tinfl_bit_buf_t)((((mz_uint64)1) << num_bits) - (mz_uint64)1);
		    r.m_dist = dist;
		    r.m_counter = counter;
		    r.m_num_extra = num_extra;
		    r.m_dist_from_out_buf_start = dist_from_out_buf_start;
		    *pIn_buf_size = pIn_buf_cur - pIn_buf_next;
		    *pOut_buf_size = pOut_buf_cur - pOut_buf_next;
		    if ((decomp_flags & (.TINFL_FLAG_PARSE_ZLIB_HEADER | .TINFL_FLAG_COMPUTE_ADLER32)) != 0 && (status >= 0))
		    {
		        mz_uint8 *ptr = pOut_buf_next;
		        size_t buf_len = *pOut_buf_size;
		        mz_uint32 i, s1 = (mz_uint32)(r.m_check_adler32 & 0xffff), s2 = (mz_uint32)(r.m_check_adler32 >> 16);
		        size_t block_len = buf_len % 5552;
		        while (buf_len > 0)
		        {
		            for (i = 0; i + 7 < block_len; i += 8, ptr += 8)
		            {
		                s1 += ptr[0]; s2 += s1;
		                s1 += ptr[1]; s2 += s1;
		                s1 += ptr[2]; s2 += s1;
		                s1 += ptr[3]; s2 += s1;
		                s1 += ptr[4]; s2 += s1;
		                s1 += ptr[5]; s2 += s1;
		                s1 += ptr[6]; s2 += s1;
		                s1 += ptr[7]; s2 += s1;
		            }
		            for (; i < block_len; ++i)
		            {
						s1 += *ptr++; s2 += s1;
					}
		            s1 %= 65521U; s2 %= 65521U;
		            buf_len -= block_len;
		            block_len = 5552;
		        }
		        r.m_check_adler32 = (s2 << 16) + s1;
		        if ((status == .TINFL_STATUS_DONE) && (decomp_flags & .TINFL_FLAG_PARSE_ZLIB_HEADER) != 0 && (r.m_check_adler32 != r.m_z_adler32))
		            status = .TINFL_STATUS_ADLER32_MISMATCH;
		    }
		    return status;
		}

		/* Higher level helper functions. */
		static void* tinfl_decompress_mem_to_heap(void *pSrc_buf, size_t src_buf_len, size_t *pOut_len, tinfl_flags flags)
		{
		    tinfl_decompressor decomp;
		    void* pBuf = null, pNew_buf;
		    size_t src_buf_ofs = 0, out_buf_capacity = 0;
		    *pOut_len = 0;
		    tinfl_init!(&decomp);
		    for (;;)
		    {
		        size_t src_buf_size = src_buf_len - src_buf_ofs, dst_buf_size = out_buf_capacity - *pOut_len, new_out_buf_capacity;
		        tinfl_status status = tinfl_decompress(&decomp, (mz_uint8 *)pSrc_buf + src_buf_ofs, &src_buf_size, (mz_uint8 *)pBuf, pBuf != null ? (mz_uint8 *)pBuf + *pOut_len : null, &dst_buf_size,
		                                               (flags & ~.TINFL_FLAG_HAS_MORE_INPUT) | .TINFL_FLAG_USING_NON_WRAPPING_OUTPUT_BUF);
		        if ((status < 0) || (status == .TINFL_STATUS_NEEDS_MORE_INPUT))
		        {
		            MZ_FREE(pBuf);
		            *pOut_len = 0;
		            return null;
		        }
		        src_buf_ofs += src_buf_size;
		        *pOut_len += dst_buf_size;
		        if (status == .TINFL_STATUS_DONE)
		            break;
		        new_out_buf_capacity = out_buf_capacity * 2;
		        if (new_out_buf_capacity < 128)
		            new_out_buf_capacity = 128;
		        pNew_buf = MZ_REALLOC(pBuf, new_out_buf_capacity);
		        if (pNew_buf == null)
		        {
		            MZ_FREE(pBuf);
		            *pOut_len = 0;
		            return null;
		        }
		        pBuf = pNew_buf;
		        out_buf_capacity = new_out_buf_capacity;
		    }
		    return pBuf;
		}

		static size_t tinfl_decompress_mem_to_mem(void *pOut_buf, size_t out_buf_len, void *pSrc_buf, size_t src_buf_len, tinfl_flags flags)
		{
			var src_buf_len;
			var out_buf_len;
		    tinfl_decompressor decomp;
		    tinfl_status status;
		    tinfl_init!(&decomp);
		    status = tinfl_decompress(&decomp, (mz_uint8 *)pSrc_buf, &src_buf_len, (mz_uint8 *)pOut_buf, (mz_uint8 *)pOut_buf, &out_buf_len, (flags & ~.TINFL_FLAG_HAS_MORE_INPUT) | .TINFL_FLAG_USING_NON_WRAPPING_OUTPUT_BUF);
		    return (status != .TINFL_STATUS_DONE) ? TINFL_DECOMPRESS_MEM_TO_MEM_FAILED : out_buf_len;
		}

		static tinfl_status tinfl_decompress_mem_to_callback(void *pIn_buf, size_t *pIn_buf_size, tinfl_put_buf_func_ptr pPut_buf_func, void *pPut_buf_user, tinfl_flags flags)
		{
		    tinfl_status result = 0;
		    tinfl_decompressor decomp;
		    mz_uint8 *pDict = (mz_uint8 *)MZ_MALLOC(TINFL_LZ_DICT_SIZE);
		    size_t in_buf_ofs = 0, dict_ofs = 0;
		    if (pDict == null)
		        return .TINFL_STATUS_FAILED;
		    tinfl_init!(&decomp);
		    for (;;)
		    {
		        size_t in_buf_size = *pIn_buf_size - in_buf_ofs, dst_buf_size = TINFL_LZ_DICT_SIZE - dict_ofs;
		        tinfl_status status = tinfl_decompress(&decomp, (mz_uint8 *)pIn_buf + in_buf_ofs, &in_buf_size, pDict, pDict + dict_ofs, &dst_buf_size,
		                                               (flags & ~(.TINFL_FLAG_HAS_MORE_INPUT | .TINFL_FLAG_USING_NON_WRAPPING_OUTPUT_BUF)));
		        in_buf_ofs += in_buf_size;
		        if ((dst_buf_size != 0) && (!pPut_buf_func(pDict + dict_ofs, (int32)dst_buf_size, pPut_buf_user)))
		            break;
		        if (status != .TINFL_STATUS_HAS_MORE_OUTPUT)
		        {
		            result = (status == .TINFL_STATUS_DONE) ? (.)1 : (.)0; // @change
		            break;
		        }
		        dict_ofs = (dict_ofs + dst_buf_size) & (TINFL_LZ_DICT_SIZE - 1);
		    }
		    MZ_FREE(pDict);
		    *pIn_buf_size = in_buf_ofs;
		    return result;
		}
	}
}
