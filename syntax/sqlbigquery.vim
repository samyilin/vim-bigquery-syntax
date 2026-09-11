" Vim syntax file
" Language:	Google BigQuery (GoogleSQL)
" Maintainer:	samyilin
" License:	Vim
" Source:	https://cloud.google.com/bigquery/docs/reference/standard-sql/lexical
"		https://cloud.google.com/bigquery/docs/reference/standard-sql/functions-all
"		https://cloud.google.com/bigquery/docs/reference/standard-sql/data-types

if exists("b:current_syntax")
  finish
endif

syn case ignore

" Literals
syn keyword sqlSpecial	false null true

" Statements (kept in sqlStatement so consumers like dbtpal.nvim keep working)
syn keyword sqlStatement	select create alter drop insert update delete merge
syn keyword sqlStatement	truncate grant revoke call execute declare set begin
syn keyword sqlStatement	commit rollback export load import

" Reserved keywords (GoogleSQL lexical reference; minus statements above)
syn keyword sqlKeyword	all and any array as asc assert_rows_modified at
syn keyword sqlKeyword	between by case cast collate cross cube
syn match sqlKeyword	"\<contains\>"
syn keyword sqlKeyword	current default define desc distinct else end enum
syn keyword sqlKeyword	escape except exclude exists extract fetch following
syn keyword sqlKeyword	for from full graph_table group grouping groups hash
syn keyword sqlKeyword	having if ignore in inner intersect interval into is
syn keyword sqlKeyword	join lateral left like limit lookup natural new no
syn keyword sqlKeyword	not nulls of on or order outer over partition
syn keyword sqlKeyword	preceding proto qualify range recursive respect right
syn keyword sqlKeyword	rollup rows some struct tablesample then to treat
syn keyword sqlKeyword	unbounded union unnest using when where window with
syn keyword sqlKeyword	within

" Additional (unreserved) keywords common in DDL/DML/query syntax
syn keyword sqlKeyword	as_of before replace if_not_exists or_replace cascade
syn keyword sqlKeyword	restrict clustered partitioned clustered_by options
syn keyword sqlKeyword	partition_by cluster_by primary foreign key references
syn keyword sqlKeyword	view materialized table schema dataset project model
syn keyword sqlKeyword	function procedure temp temporary unique values value
syn keyword sqlKeyword	target source matched pivot unpivot qualify window
syn keyword sqlKeyword	collate grouping_sets cube rollup
syn keyword sqlKeyword	offset fetch first next rows_only with_ties percent
syn keyword sqlKeyword	recursive system_time for_system_time
syn keyword sqlKeyword	deterministic returns language js external remote
syn keyword sqlKeyword	connection location

" Operators
syn keyword sqlOperator	not and or on in any some all between exists
syn keyword sqlOperator	like escape unnest union intersect except distinct
syn keyword sqlOperator	interval is

" Data types (https://cloud.google.com/bigquery/docs/reference/standard-sql/data-types)
syn keyword sqlType	int64 int smallint integer bigint tinyint byteint
syn keyword sqlType	float64 float decimal numeric bignumeric bigdecimal
syn keyword sqlType	bool boolean string bytes date datetime time timestamp
syn keyword sqlType	interval json geography array struct range uuid
syn keyword sqlType	microsecond millisecond second minute hour dayofweek day
syn keyword sqlType	dayofyear week isoweek month quarter year isoyear

" Strings: '...' "..." """...""" `project.dataset.table` BQ raw/byte literals
syn region sqlString	matchgroup=Quote start=+b\?"+ skip=+\\"+ end=+"+
syn region sqlString	matchgroup=Quote start=+b\?"""+ end=+"""+
syn region sqlString	matchgroup=Quote start=+[bB]\?'+ skip=+\\'+ end=+'+
syn region sqlString	matchgroup=Quote start=+`+ end=+`+

" Numbers
syn match sqlNumber	"-\=\<\d*\.\=[0-9_]\>"

" Comments (-- ... and /* ... */)
syn region sqlComment	start="/\*" end="\*/" contains=sqlTodo,@Spell fold
syn match sqlComment	"--.*$" contains=sqlTodo,@Spell
syn match sqlComment	"#.*$" contains=sqlTodo,@Spell

" Folding on statement starts
syn region sqlFold start='^\s*\zs\c\(Create\|Update\|Alter\|Select\|Insert\|Merge\|Delete\|With\)' end=';$\|^$' transparent fold contains=ALL

syn sync ccomment sqlComment

" Functions (grouped per functions-all reference; dotted names use last part)
" AEAD
syn keyword sqlFunction	aead encrypt decrypt_bytes decrypt_string
syn keyword sqlFunction	deterministic_encrypt deterministic_decrypt_bytes
syn keyword sqlFunction	deterministic_decrypt_string add_key_from_raw_bytes
syn keyword sqlFunction	keyset_chain keyset_from_json keyset_length
syn keyword sqlFunction	keyset_to_json new_keyset new_wrapped_keyset
syn keyword sqlFunction	rewrap_keyset rotate_keyset rotate_wrapped_keyset
" Aggregate / approx / HLL / KLL
syn keyword sqlFunction	array_agg any_value array_concat_agg avg bit_and
syn keyword sqlFunction	bit_or bit_xor count countif logical_and logical_or
syn keyword sqlFunction	max max_by min min_by string_agg sum grouping
syn keyword sqlFunction	approx_count_distinct approx_quantiles approx_top_count
syn keyword sqlFunction	approx_top_sum hll_count extract init merge
syn keyword sqlFunction	merge_partial
" Array / range
syn keyword sqlFunction	array array_concat array_first array_last
syn keyword sqlFunction	array_length array_reverse array_slice array_to_string
syn keyword sqlFunction	generate_array generate_date_array
syn keyword sqlFunction	generate_timestamp_array generate_range_array offset
syn keyword sqlFunction	ordinal safe_offset safe_ordinal range_contains
syn keyword sqlFunction	range_start range_end range_intersect range_overlaps
syn keyword sqlFunction	range_sessionize
" Conversion / debug / utility / security / federated / search
syn keyword sqlFunction	cast parse_bignumeric parse_numeric safe_cast
syn keyword sqlFunction	error generate_uuid typeof session_user
syn keyword sqlFunction	external_query external_object_transform search
syn keyword sqlFunction	vector_search fetch_metadata get_access_url
syn keyword sqlFunction	get_read_url make_ref
" Date / datetime / time / timestamp / interval
syn keyword sqlFunction	current_date date date_add date_diff
syn keyword sqlFunction	date_from_unix_date date_sub date_trunc extract
syn keyword sqlFunction	format_date last_day parse_date unix_date date_bucket
syn keyword sqlFunction	current_datetime datetime datetime_add datetime_diff
syn keyword sqlFunction	datetime_sub datetime_trunc format_datetime
syn keyword sqlFunction	parse_datetime datetime_bucket
syn keyword sqlFunction	current_time format_time parse_time time time_add
syn keyword sqlFunction	time_diff time_sub time_trunc
syn keyword sqlFunction	current_timestamp format_timestamp parse_timestamp
syn keyword sqlFunction	timestamp timestamp_add timestamp_diff
syn keyword sqlFunction	timestamp_micros timestamp_millis timestamp_seconds
syn keyword sqlFunction	timestamp_sub timestamp_trunc unix_micros unix_millis
syn keyword sqlFunction	unix_seconds timestamp_bucket
syn keyword sqlFunction	justify_days justify_hours justify_interval make_interval
" Geography
syn keyword sqlFunction	s2_cellidfrompoint s2_coveringcellids st_angle
syn keyword sqlFunction	st_area st_asbinary st_asgeojson st_astext st_azimuth
syn keyword sqlFunction	st_boundary st_boundingbox st_buffer st_bufferwithtolerance
syn keyword sqlFunction	st_centroid st_centroid_agg st_closestpoint
syn keyword sqlFunction	st_clusterdbscan st_contains st_convexhull st_coveredby
syn keyword sqlFunction	st_covers st_difference st_dimension st_disjoint
syn keyword sqlFunction	st_distance st_dump st_dwithin st_endpoint st_equals
syn keyword sqlFunction	st_extent st_exteriorring st_geogfrom st_geogfromgeojson
syn keyword sqlFunction	st_geogfromtext st_geogfromwkb st_geogpoint
syn keyword sqlFunction	st_geogpointfromgeohash st_geohash st_geometrytype
syn keyword sqlFunction	st_hausdorffdistance st_hausdorffdwithin
syn keyword sqlFunction	st_interiorrings st_intersection st_intersects
syn keyword sqlFunction	st_intersectsbox st_isclosed st_iscollection st_isempty
syn keyword sqlFunction	st_isring st_length st_lineinterpolatepoint
syn keyword sqlFunction	st_linelocatepoint st_linesubstring st_makeline
syn keyword sqlFunction	st_makepolygon st_makepolygonoriented st_maxdistance
syn keyword sqlFunction	st_npoints st_numgeometries st_numpoints st_perimeter
syn keyword sqlFunction	st_pointn st_regionstats st_simplify st_snaptogrid
syn keyword sqlFunction	st_startpoint st_touches st_union st_union_agg
syn keyword sqlFunction	st_within st_x st_y
" Hash / math / bit
syn keyword sqlFunction	farm_fingerprint md5 sha1 sha256 sha512 bit_count
syn keyword sqlFunction	abs acos acosh asin asinh atan atan2 atanh cbrt ceil
syn keyword sqlFunction	ceiling cos cosh cosine_distance cot coth csc csch
syn keyword sqlFunction	div exp euclidean_distance floor greatest is_inf
syn keyword sqlFunction	is_nan least ln log log10 mod pow power rand range
syn keyword sqlFunction	range_bucket round safe_add safe_divide safe_multiply
syn keyword sqlFunction	safe_negate safe_subtract sec sech sign sin sinh
syn keyword sqlFunction	sqrt tan tanh trunc ieee_divide
" JSON
syn keyword sqlFunction	json_array json_array_append json_array_insert
syn keyword sqlFunction	json_extract json_extract_array json_extract_scalar
syn keyword sqlFunction	json_extract_string_array json_flatten json_keys
syn keyword sqlFunction	json_object json_query json_query_array json_remove
syn keyword sqlFunction	json_set json_strip_nulls json_type json_value
syn keyword sqlFunction	json_value_array lax_bool lax_float64 lax_int64
syn keyword sqlFunction	lax_string parse_json to_json to_json_string
" Navigation / numbering / statistical
syn keyword sqlFunction	first_value lag last_value lead nth_value
syn keyword sqlFunction	percentile_cont percentile_disc
syn keyword sqlFunction	cume_dist dense_rank ntile percent_rank rank row_number
syn keyword sqlFunction	corr covar_pop covar_samp stddev stddev_pop
syn keyword sqlFunction	stddev_samp var_pop var_samp variance
" Net
syn keyword sqlFunction	host ip_from_string ip_net_mask ip_to_string ip_trunc
syn keyword sqlFunction	ipv4_from_int64 ipv4_to_int64 public_suffix reg_domain
syn keyword sqlFunction	safe_ip_from_string
" String
syn keyword sqlFunction	ascii byte_length char_length character_length chr
syn keyword sqlFunction	code_points_to_bytes code_points_to_string collate
syn keyword sqlFunction	concat contains_substr edit_distance ends_with format
syn keyword sqlFunction	from_base32 from_base64 from_hex initcap instr left
syn keyword sqlFunction	length lower lpad ltrim normalize normalize_and_casefold
syn keyword sqlFunction	octet_length regexp_contains regexp_extract
syn keyword sqlFunction	regexp_extract_all regexp_instr regexp_replace
syn keyword sqlFunction	regexp_substr repeat replace reverse right rpad rtrim
syn keyword sqlFunction	safe_convert_bytes_to_string soundex split starts_with
syn keyword sqlFunction	strpos substr substring to_base32 to_base64
syn keyword sqlFunction	to_code_points to_hex translate trim unicode upper
" Text analysis / time series
syn keyword sqlFunction	bag_of_words text_analyze tf_idf appends changes gap_fill
" ML / AI (prefix-less entry points commonly used in queries)
syn keyword sqlFunction	predict evaluate transform imputer bucketize max_abs_scaler
syn keyword sqlFunction	min_max_scaler normalizer polynomial_expand
syn keyword sqlFunction	quantile_bucketize robust_scaler standard_scaler
syn keyword sqlFunction	feature_cross hash_bucketize label_encoder
syn keyword sqlFunction	multi_hot_encoder one_hot_encoder ngrams tf_idf
syn keyword sqlFunction	forecast explain_predict global_explain weights
syn keyword sqlFunction	centroids confusion_matrix roc_curve foreground
syn keyword sqlFunction	ai_generate ai_generate_bool ai_generate_double
syn keyword sqlFunction	ai_generate_int ai_evaluate ai_forecast ai_translate

syn keyword sqlTodo TODO FIXME XXX DEBUG NOTE contained

hi def link Quote		Special
hi def link sqlComment		Comment
hi def link sqlFunction		Function
hi def link sqlKeyword		sqlSpecial
hi def link sqlNumber		Number
hi def link sqlOperator		sqlStatement
hi def link sqlSpecial		Special
hi def link sqlStatement	Statement
hi def link sqlString		String
hi def link sqlType		Type
hi def link sqlTodo		Todo
let b:current_syntax = "sqlbigquery"
" vim: ts=8
