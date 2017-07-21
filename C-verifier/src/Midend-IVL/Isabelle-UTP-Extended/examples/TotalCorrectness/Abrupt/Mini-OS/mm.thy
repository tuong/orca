subsection \<open>Memory mapping\<close>

theory mm
imports
  "../../../../../../Backend/VCG/VCG_total_ML"
begin

subsubsection \<open>From other header files\<close>

text \<open>Implementation-dependent; assuming ARM for now.\<close>
abbreviation "SIZEOF_INT \<equiv> \<guillemotleft>32\<guillemotright>" (* Necessary for the bitshifts *)

abbreviation "PAGE_SHIFT \<equiv> \<guillemotleft>12\<guillemotright>"
abbreviation "PAGE_SIZE \<equiv> 1 \<lless>\<^bsub>u/SIZEOF_INT\<^esub> PAGE_SHIFT"
abbreviation "PAGE_MASK \<equiv> \<not>\<^bsub>u/SIZEOF_INT\<^esub> (PAGE_SIZE - 1)"

subsubsection \<open>From header file @{text mm.h}}\<close>

text \<open>sizeof(unsigned long); assuming non-Windows 64-bit architecture.\<close>
abbreviation "SIZEOF_ULONG \<equiv> \<guillemotleft>64::nat\<guillemotright>"

abbreviation "round_pgdown p \<equiv> p \<and>\<^sub>b\<^sub>u PAGE_MASK"
abbreviation "round_pgup p \<equiv> (p + PAGE_SIZE - 1) \<and>\<^sub>b\<^sub>u PAGE_MASK"

definition "get_order
  (* input *) size
  (* local variables *) order
  =
  size \<Midarrow> (&size - 1) \<ggreater>\<^bsub>u/SIZEOF_ULONG\<^esub> PAGE_SHIFT;;
  order \<Midarrow> \<guillemotleft>0\<guillemotright>;;
  (* TODO: assumption *)
  while &size \<noteq>\<^sub>u 0
  invr true (* TODO: fix *)
  do
    II;;
    order \<Midarrow> &order + 1
  od
  (* return order *)
  "

subsubsection \<open>From source file @{text mm.c}\<close>

abbreviation "PAGES_PER_MAPWORD \<equiv> SIZEOF_ULONG * 8"

abbreviation allocated_in_map :: "(nat list, '\<alpha>) uexpr \<Rightarrow> (nat, '\<alpha>) uexpr \<Rightarrow> (nat, '\<alpha>) uexpr" where
  "allocated_in_map bitmap pn \<equiv>
    bitmap\<lparr>pn div PAGES_PER_MAPWORD\<rparr>\<^sub>u \<and>\<^sub>b\<^sub>u
    1 \<lless>\<^bsub>u/SIZEOF_ULONG\<^esub> (pn \<and>\<^sub>b\<^sub>u (PAGES_PER_MAPWORD - 1))"

text \<open>Currently representing functions as individual definitions (without Hoare triples); this is
slightly troublesome as it requires passing in local variables to have them treated as such, but
that might just be an issue with my setup.\<close>
definition "map_alloc
  (* inputs *) first_page nr_pages
  (* global variables *) mm_alloc_bitmap nr_free_pages
  (* local variables *) curr_idx_start curr_idx start_off end_idx end_off temp
  =
  curr_idx_start \<Midarrow> &first_page div PAGES_PER_MAPWORD;;
  curr_idx  \<Midarrow> &curr_idx_start;;
  start_off \<Midarrow> &first_page \<and>\<^sub>b\<^sub>u (PAGES_PER_MAPWORD - 1);;
  end_idx   \<Midarrow> (&first_page + &nr_pages) div PAGES_PER_MAPWORD;;
  end_off   \<Midarrow> (&first_page + &nr_pages) \<and>\<^sub>b\<^sub>u (PAGES_PER_MAPWORD - 1);;

  (&curr_idx_start =\<^sub>u &first_page div PAGES_PER_MAPWORD \<and>
   &curr_idx =\<^sub>u &curr_idx_start \<and>
   &start_off =\<^sub>u &first_page \<and>\<^sub>b\<^sub>u (PAGES_PER_MAPWORD - 1) \<and>
   &end_idx =\<^sub>u (&first_page + &nr_pages) div PAGES_PER_MAPWORD \<and>
   &end_off =\<^sub>u (&first_page + &nr_pages) \<and>\<^sub>b\<^sub>u (PAGES_PER_MAPWORD - 1))\<^sup>\<top>\<^sup>C;;
  bif &curr_idx =\<^sub>u &end_idx then
    temp \<Midarrow> 1 \<lless>\<^bsub>u/SIZEOF_ULONG\<^esub> &end_off - 1;;
    temp \<Midarrow> &temp \<and>\<^sub>b\<^sub>u -\<^bsub>u/SIZEOF_ULONG\<^esub>(1 \<lless>\<^bsub>u/SIZEOF_ULONG\<^esub> &start_off);;
    temp \<Midarrow> (&mm_alloc_bitmap:\<^sub>u nat list)\<lparr>&curr_idx\<rparr>\<^sub>u \<or>\<^sub>b\<^sub>u &temp;;
    mm_alloc_bitmap \<Midarrow> &mm_alloc_bitmap(&curr_idx \<mapsto> &temp)\<^sub>u
  else
    temp \<Midarrow> -\<^bsub>u/SIZEOF_ULONG\<^esub>(1 \<lless>\<^bsub>u/SIZEOF_ULONG\<^esub> &start_off);;
    temp \<Midarrow> &mm_alloc_bitmap\<lparr>&curr_idx\<rparr>\<^sub>u \<or>\<^sub>b\<^sub>u &temp;;
    mm_alloc_bitmap \<Midarrow> &mm_alloc_bitmap(&curr_idx \<mapsto> &temp)\<^sub>u;;
    (&curr_idx_start =\<^sub>u &first_page div PAGES_PER_MAPWORD \<and>
     &curr_idx =\<^sub>u &curr_idx_start \<and>
     &start_off =\<^sub>u &first_page \<and>\<^sub>b\<^sub>u (PAGES_PER_MAPWORD - 1) \<and>
     &end_idx =\<^sub>u (&first_page + &nr_pages) div PAGES_PER_MAPWORD \<and>
     &end_off =\<^sub>u (&first_page + &nr_pages) \<and>\<^sub>b\<^sub>u (PAGES_PER_MAPWORD - 1) \<and>
     &mm_alloc_bitmap\<lparr>&curr_idx\<rparr>\<^sub>u \<and>\<^sub>b\<^sub>u -\<^bsub>u/SIZEOF_ULONG\<^esub>(1 \<lless>\<^bsub>u/SIZEOF_ULONG\<^esub> &start_off) =\<^sub>u -\<^bsub>u/SIZEOF_ULONG\<^esub>(1 \<lless>\<^bsub>u/SIZEOF_ULONG\<^esub> &start_off)
    )\<^sup>\<top>\<^sup>C;;
    while &curr_idx + 1 <\<^sub>u &end_idx
    invr
      &curr_idx \<ge>\<^sub>u &curr_idx_start \<and>
      &curr_idx <\<^sub>u &end_idx \<and>
      (* TODO: may need a different formulation of the below if the set is not empty for
        &curr_idx_start =\<^sub>u &curr_idx *)
      (\<^bold>\<forall> i \<in> {&curr_idx_start..&curr_idx}\<^sub>u \<bullet> &mm_alloc_bitmap\<lparr>\<guillemotleft>i\<guillemotright>\<rparr>\<^sub>u =\<^sub>u \<not>\<^bsub>u/SIZEOF_ULONG\<^esub> 0)
    do
      curr_idx \<Midarrow> &curr_idx + 1;;
      mm_alloc_bitmap \<Midarrow> &mm_alloc_bitmap(&curr_idx \<mapsto> \<not>\<^bsub>u/SIZEOF_ULONG\<^esub> 0)\<^sub>u
    od;;
    curr_idx \<Midarrow> &curr_idx + 1;; (* needed for last increment *)
    temp \<Midarrow> (1 \<lless>\<^bsub>u/SIZEOF_ULONG\<^esub> &end_off) - 1;;
    temp \<Midarrow> &mm_alloc_bitmap\<lparr>&curr_idx\<rparr>\<^sub>u \<or>\<^sub>b\<^sub>u &temp;;
    mm_alloc_bitmap \<Midarrow> &mm_alloc_bitmap(&curr_idx \<mapsto> &temp)\<^sub>u
  eif;;

  nr_free_pages \<Midarrow> &nr_free_pages - &nr_pages (* Global, so should use :==? Only if in alphabet... *)
  "

definition "map_free
  (* inputs *) first_page nr_pages
  (* global variables *) mm_alloc_bitmap nr_free_pages
  (* local variables *) curr_idx_start curr_idx start_off end_idx end_off temp
  =
  curr_idx_start \<Midarrow> &first_page div PAGES_PER_MAPWORD;;
  curr_idx  \<Midarrow> &curr_idx_start;;
  start_off \<Midarrow> &first_page \<and>\<^sub>b\<^sub>u (PAGES_PER_MAPWORD - 1);;
  end_idx   \<Midarrow> (&first_page + &nr_pages) div PAGES_PER_MAPWORD;;
  end_off   \<Midarrow> (&first_page + &nr_pages) \<and>\<^sub>b\<^sub>u (PAGES_PER_MAPWORD - 1);;
  nr_free_pages \<Midarrow> &nr_free_pages + &nr_pages;; (* Global, so should use :==? Only if in alphabet... *)

  (&curr_idx_start =\<^sub>u &first_page div PAGES_PER_MAPWORD \<and>
   &curr_idx =\<^sub>u &curr_idx_start \<and>
   &start_off =\<^sub>u &first_page \<and>\<^sub>b\<^sub>u (PAGES_PER_MAPWORD - 1) \<and>
   &end_idx =\<^sub>u (&first_page + &nr_pages) div PAGES_PER_MAPWORD \<and>
   &end_off =\<^sub>u (&first_page + &nr_pages) \<and>\<^sub>b\<^sub>u (PAGES_PER_MAPWORD - 1) \<and>
   &nr_free_pages \<ge>\<^sub>u &nr_pages
  )\<^sup>\<top>\<^sup>C;;
  bif &curr_idx =\<^sub>u &end_idx then
    temp \<Midarrow> -\<^bsub>u/SIZEOF_ULONG\<^esub> (1 \<lless>\<^bsub>u/SIZEOF_ULONG\<^esub> &end_off);;
    temp \<Midarrow> &temp \<or>\<^sub>b\<^sub>u (1 \<lless>\<^bsub>u/SIZEOF_ULONG\<^esub> &start_off - 1);;
    temp \<Midarrow> (&mm_alloc_bitmap:\<^sub>u nat list)\<lparr>&curr_idx\<rparr>\<^sub>u \<and>\<^sub>b\<^sub>u &temp;;
    mm_alloc_bitmap \<Midarrow> &mm_alloc_bitmap(&curr_idx \<mapsto> &temp)\<^sub>u
  else
    temp \<Midarrow> 1 \<lless>\<^bsub>u/SIZEOF_ULONG\<^esub> &start_off - 1;;
    temp \<Midarrow> &mm_alloc_bitmap\<lparr>&curr_idx\<rparr>\<^sub>u \<and>\<^sub>b\<^sub>u &temp;;
    mm_alloc_bitmap \<Midarrow> (&mm_alloc_bitmap)(&curr_idx \<mapsto> &temp)\<^sub>u;;
    (&curr_idx_start =\<^sub>u &first_page div PAGES_PER_MAPWORD \<and>
     &curr_idx =\<^sub>u &curr_idx_start \<and>
     &start_off =\<^sub>u &first_page \<and>\<^sub>b\<^sub>u (PAGES_PER_MAPWORD - 1) \<and>
     &end_idx =\<^sub>u (&first_page + &nr_pages) div PAGES_PER_MAPWORD \<and>
     &end_off =\<^sub>u (&first_page + &nr_pages) \<and>\<^sub>b\<^sub>u (PAGES_PER_MAPWORD - 1) \<and>
     &mm_alloc_bitmap\<lparr>&curr_idx\<rparr>\<^sub>u \<or>\<^sub>b\<^sub>u (1 \<lless>\<^bsub>u/SIZEOF_ULONG\<^esub> &start_off - 1) =\<^sub>u 1 \<lless>\<^bsub>u/SIZEOF_ULONG\<^esub> &start_off - 1
    )\<^sup>\<top>\<^sup>C;;
    while &curr_idx + 1 <\<^sub>u &end_idx
    invr
      &curr_idx \<ge>\<^sub>u &curr_idx_start \<and>
      &curr_idx <\<^sub>u &end_idx \<and>
      (* TODO: may need a different formulation of the below if the set is not empty for
        &curr_idx_start =\<^sub>u &curr_idx *)
      (\<^bold>\<forall> i \<in> {&curr_idx_start..&curr_idx}\<^sub>u \<bullet> &mm_alloc_bitmap\<lparr>\<guillemotleft>i\<guillemotright>\<rparr>\<^sub>u =\<^sub>u 0)
    do
      curr_idx \<Midarrow> &curr_idx + 1;;
      mm_alloc_bitmap \<Midarrow> &mm_alloc_bitmap(&curr_idx \<mapsto> 0)\<^sub>u
    od;;
    curr_idx \<Midarrow> &curr_idx + 1;; (* needed for last increment *)
    temp \<Midarrow> -\<^bsub>u/SIZEOF_ULONG\<^esub> (1 \<lless>\<^bsub>u/SIZEOF_ULONG\<^esub> &end_off);;
    temp \<Midarrow> &mm_alloc_bitmap\<lparr>&curr_idx\<rparr>\<^sub>u \<and>\<^sub>b\<^sub>u &temp;;
    mm_alloc_bitmap \<Midarrow> &mm_alloc_bitmap(&curr_idx \<mapsto> &temp)\<^sub>u
  eif
  "

(* init_page_allocator needs structs and pointers *)
(* alloc_pages needs structs and pointers *)
(* free_pages needs structs and pointers *)
(* free_physical_pages needs structs, function calls *)
(* map_frame_rw needs function calls *)
(* sbrk needs function calls/pointers *)
(* init_mm needs function calls *)

definition "fini_mm \<equiv> II"

(* sanity_check needs pointers, function calls *)

end
