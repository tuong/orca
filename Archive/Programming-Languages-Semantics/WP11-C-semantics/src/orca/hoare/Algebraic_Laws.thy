 
section {*Algebraic laws of programming*}

text{*In this section we introduce the semantic rules related to the different
      statements of IMP. In the literature this also known as the algebraic laws of programming.
      In our framework we will use these rules in order to optimize a given program written in our 
      language, and this before any deductive proof verification activity or formal testing.*}

theory Algebraic_Laws
imports "../utp/utp_urel_laws"
begin

named_theorems symbolic_exec and symbolic_exec_assign_uop and symbolic_exec_assign_bop and 
               symbolic_exec_assign_trop and symbolic_exec_assign_qtop and symbolic_exec_ex
(* Usage of symbolic_exec_ex for the simp lemmas avoids annoying warnings about duplicate theorems
when using `simp add: symbolic_exec` *)

subsection {*SKIP Laws*}
text{*In this section we introduce the algebraic laws of programming related to the SKIP
      statement.*}

lemma seqr_left_unit [simp, symbolic_exec_ex]:
  "II ;; P = P"
  by rel_auto

lemma seqr_right_unit [simp, symbolic_exec_ex]:
  "P ;; II = P"
  by rel_auto

lemma pre_skip_post: "(\<lceil>b\<rceil>\<^sub>< \<and> II) = (II \<and> \<lceil>b\<rceil>\<^sub>>)"
  by rel_auto

lemma skip_var:
  fixes x :: "(bool, '\<alpha>) uvar"
  shows "($x \<and> II) = (II \<and> $x\<acute>)"
  by rel_auto

lemma assign_r_alt_def [symbolic_exec]:
  fixes x :: "('a, '\<alpha>) uvar"
  shows "x :== v = II\<lbrakk>\<lceil>v\<rceil>\<^sub></$x\<rbrakk>"
  by rel_auto

lemma skip_r_alpha_eq:
  "II = ($\<Sigma>\<acute> =\<^sub>u $\<Sigma>)"
  by rel_auto

subsection {*Assignment Laws*}
text{*In this section we introduce the algebraic laws of programming related to the assignment
      statement.*}

lemma "&v\<lbrakk>expr/v\<rbrakk> = [v \<mapsto>\<^sub>s expr] \<dagger> &v" ..

lemma usubst_cancel[usubst,symbolic_exec]: 
  assumes 1:"weak_lens v" 
  shows "(&v)\<lbrakk>expr/v\<rbrakk> = expr"
  using 1
  by transfer' rel_auto

lemma usubst_cancel_r[usubst,symbolic_exec]: 
  assumes 1:"weak_lens v" 
  shows "($v)\<lbrakk>\<lceil>expr\<rceil>\<^sub></$v\<rbrakk>= \<lceil>expr\<rceil>\<^sub><"
  using 1
  by  rel_auto

lemma assign_test[symbolic_exec]:
  assumes 1:"mwb_lens x" 
  shows     "(x :== \<guillemotleft>u\<guillemotright> ;; x :== \<guillemotleft>v\<guillemotright>) = (x :== \<guillemotleft>v\<guillemotright>)"
  using 1   
  by (simp add: assigns_comp subst_upd_comp subst_lit usubst_upd_idem)

lemma assign_r_comp[symbolic_exec]: 
  "(x :== u ;; P) = P\<lbrakk>\<lceil>u\<rceil>\<^sub></$x\<rbrakk>" 
  by (simp add: assigns_r_comp usubst)

lemma assign_twice[symbolic_exec]: 
  assumes "mwb_lens x" and  "x \<sharp> f" 
  shows "(x :== e ;; x :== f) = (x :== f)" 
  using assms
  by (simp add: assigns_comp usubst)

lemma assign_commute:
  assumes "x \<bowtie> y" "x \<sharp> f" "y \<sharp> e"
  shows "(x :== e ;; y :== f) = (y :== f ;; x :== e)"
  using assms
  by (rel_auto, simp_all add: lens_indep_comm)

lemma assign_cond:
  fixes x :: "('a, '\<alpha>) uvar"
  assumes "out\<alpha> \<sharp> b"
  shows "(x :== e ;; (P \<triangleleft> b \<triangleright> Q)) = 
         ((x :== e ;; P) \<triangleleft>(b\<lbrakk>\<lceil>e\<rceil>\<^sub></$x\<rbrakk>)\<triangleright> (x :== e ;; Q))"
  by rel_auto

lemma assign_rcond[symbolic_exec]:
  fixes x :: "('a, '\<alpha>) uvar"
  shows "(x :== e ;; (P \<triangleleft> b \<triangleright>\<^sub>r Q)) = ((x :== e ;; P) \<triangleleft> (b\<lbrakk>e/x\<rbrakk>) \<triangleright>\<^sub>r (x :== e ;; Q))"
  by rel_auto

lemma assign_uop1[symbolic_exec_assign_uop]: 
  assumes 1: "mwb_lens v"
  shows "(v:== e1 ;; v:== (uop F (&v))) = (v:== (uop F e1))"
  using 1 
  by rel_auto

lemma assign_bop1[symbolic_exec_assign_bop]: 
  assumes 1: "mwb_lens v" and 2:"v \<sharp> e2"
  shows "(v:== e1 ;; v:== (bop bp (&v) e2)) = (v:== (bop bp e1 e2))"
  using 1 2  
  by rel_auto

lemma assign_bop2[symbolic_exec_assign_bop]: 
  assumes 1: "mwb_lens v" and 2:"v \<sharp> e2"
  shows "(v:== e1 ;; v:== (bop bp e2 (&v))) = (v:== (bop bp e2 e1))"
  using 1 2  
  by rel_auto

lemma assign_trop1[symbolic_exec_assign_trop]: 
  assumes 1: "mwb_lens v" and 2:"v \<sharp> e2" and 3:"v \<sharp> e3"
  shows "(v:== e1 ;; v:== (trop tp (&v) e2 e3)) = 
         (v:== (trop tp e1 e2 e3))"
  using 1 2 3
  by rel_auto

lemma assign_trop2[symbolic_exec_assign_trop]: 
  assumes 1: "mwb_lens v" and 2:"v \<sharp> e2" and 3:"v \<sharp> e3"
  shows "(v:== e1 ;; v:== (trop tp e2 (&v) e3)) = 
         (v:== (trop tp e2 e1 e3))"
  using 1 2 3
  by rel_auto

lemma assign_trop3[symbolic_exec_assign_trop]: 
  assumes 1: "mwb_lens v" and 2:"v \<sharp> e2" and 3:"v \<sharp> e3"
  shows "(v:== e1 ;; v:== (trop tp e2 e3 (&v))) = 
         (v:== (trop tp e2 e3 e1))"
  using 1 2 3
  by rel_auto

lemma assign_qtop1[symbolic_exec_assign_qtop]: 
  assumes 1: "mwb_lens v" and 2:"v \<sharp> e2" and 3:"v \<sharp> e3" and 4:"v \<sharp> e4"
  shows "(v:== e1 ;; v:== (qtop tp (&v) e2 e3 e4)) = 
         (v:== (qtop tp e1 e2 e3 e4))"
  using 1 2 3 4
  by rel_auto

lemma assign_qtop2[symbolic_exec_assign_qtop]: 
  assumes 1: "mwb_lens v" and 2:"v \<sharp> e2" and 3:"v \<sharp> e3" and 4:"v \<sharp> e4"
  shows "(v:== e1 ;; v:== (qtop tp e2 (&v) e3 e4)) = 
         (v:== (qtop tp e2 e1 e3 e4))"
  using 1 2 3 4
  by rel_auto

lemma assign_qtop3[symbolic_exec_assign_qtop]: 
  assumes 1: "mwb_lens v" and 2:"v \<sharp> e2" and 3:"v \<sharp> e3" and 4:"v \<sharp> e4"
  shows "(v:== e1 ;; v:== (qtop tp e2 e3 (&v) e4)) = 
         (v:== (qtop tp e2 e3 e1 e4))"
  using 1 2 3 4
  by rel_auto

lemma assign_qtop4[symbolic_exec_assign_qtop]: 
  assumes 1: "mwb_lens v" and 2:"v \<sharp> e2" and 3:"v \<sharp> e3" and 4:"v \<sharp> e4"
  shows "(v:== e1 ;; v:== (qtop tp e2 e3 e4 (&v))) = 
         (v:== (qtop tp e2 e3 e4 e1))"
  using 1 2 3 4
  by rel_auto

lemma assign_cond_seqr_dist[symbolic_exec]:
  "((v:== e ;; P) \<triangleleft> (b\<lbrakk>\<lceil>e\<rceil>\<^sub></$v\<rbrakk>) \<triangleright> (v:== e ;; Q)) = 
   (v:== e ;; P \<triangleleft> b \<triangleright> Q)" 
  by rel_auto

text {*In the sequel we find assignment laws proposed by Hoare*}

lemma assign_vwb_skip:
  assumes 1: "vwb_lens v"
  shows "(v:== &v) = II"
  by (simp add: assms skip_r_def usubst_upd_var_id)

lemma assign_simultaneous:
  assumes  1: "vwb_lens var2"
  and      2: "var1 \<bowtie> var2"
  shows "(var1, var2 :== exp, &var2) = (var1 :== exp)"
  by (simp add: "1" "2" usubst_upd_comm usubst_upd_var_id)

lemma assign_seq:
  assumes  1: "vwb_lens var2"
  shows"(var1:== exp);; (var2 :== &var2) = (var1:== exp)"
  using 1 by rel_auto

lemma assign_cond_uop[symbolic_exec_assign_uop]:
  assumes 1: "weak_lens v"
  shows "(v:== exp ;; C1) \<triangleleft>uop F exp\<triangleright>\<^sub>r (v:== exp ;; C2) = 
          v:== exp ;; C1 \<triangleleft>uop F (&v)\<triangleright>\<^sub>r  C2"
  using 1 
  by rel_auto

lemma assign_cond_bop1[symbolic_exec_assign_bop]:
  assumes 1: "weak_lens v" and 2: "v \<sharp> exp2"
  shows "(v:== exp ;; C1 \<triangleleft>(bop bp (&v) exp2)\<triangleright>\<^sub>r C2) = 
         ((v:== exp ;; C1) \<triangleleft>(bop bp exp exp2)\<triangleright>\<^sub>r  (v:== exp ;; C2))"
  using 1 2 
  by rel_auto

lemma assign_cond_bop2[symbolic_exec_assign_bop]:
  assumes 1: "weak_lens v" and 2: "v \<sharp> exp2"
  shows "(v:== exp1 ;; C1 \<triangleleft>(bop bp exp2 (&v))\<triangleright>\<^sub>r C2) = 
         ((v:== exp1 ;; C1) \<triangleleft>(bop bp exp2 exp1)\<triangleright>\<^sub>r (v:== exp1 ;; C2))"
  using 1 2 
  by rel_auto

lemma assign_cond_trop1[symbolic_exec_assign_trop]:
  assumes 1: "weak_lens v" and 2: "v \<sharp> exp2" and 3: "v \<sharp> exp3"
  shows "(v:== exp ;; C1 \<triangleleft>(trop tp (&v) exp2 exp3)\<triangleright>\<^sub>r C2) = 
         ((v:== exp ;; C1) \<triangleleft>(trop tp exp exp2 exp3)\<triangleright>\<^sub>r (v:== exp ;; C2))"
  using 1 2 3
  by rel_auto

lemma assign_cond_trop2[symbolic_exec_assign_trop]:
  assumes 1: "weak_lens v" and 2: "v \<sharp> exp2" and 3: "v \<sharp> exp3"
  shows "(v:== exp1 ;; C1 \<triangleleft>(trop tp exp2 (&v) exp3)\<triangleright>\<^sub>r C2) = 
         ((v:== exp1 ;; C1) \<triangleleft>(trop tp exp2 exp1 exp3)\<triangleright>\<^sub>r (v:== exp1 ;; C2))"
  using 1 2 3 
  by rel_auto

lemma assign_cond_trop3[symbolic_exec_assign_trop]:
  assumes 1: "weak_lens v" and 2: "v \<sharp> exp2" and 3: "v \<sharp> exp3"
  shows "(v:== exp1 ;; C1 \<triangleleft>(trop bp exp2 exp3 (&v))\<triangleright>\<^sub>r C2) = 
         ((v:== exp1 ;; C1) \<triangleleft>(trop bp exp2 exp3 exp1)\<triangleright>\<^sub>r (v:== exp1 ;; C2))"
  using 1 2 3 
  by rel_auto

lemma assign_cond_qtop1[symbolic_exec_assign_qtop]:
  assumes 1: "weak_lens v" and 2: "v \<sharp> exp2" and 3: "v \<sharp> exp3" and 4: "v \<sharp> exp4"
  shows "(v:== exp1 ;;  C1 \<triangleleft>(qtop tp (&v) exp2 exp3 exp4)\<triangleright>\<^sub>r C2) = 
         ((v:== exp1 ;; C1) \<triangleleft>(qtop tp exp1 exp2 exp3  exp4)\<triangleright>\<^sub>r (v:== exp1 ;; C2))"
  using 1 2 3 4
  by rel_auto

lemma assign_cond_qtop2[symbolic_exec_assign_qtop]:
  assumes 1: "weak_lens v" and 2: "v \<sharp> exp2" and 3: "v \<sharp> exp3" and 4:"v \<sharp> exp4"
  shows "(v:== exp1 ;; C1 \<triangleleft>(qtop tp exp2 (&v) exp3 exp4)\<triangleright>\<^sub>r C2) = 
         ((v:== exp1 ;; C1) \<triangleleft>(qtop tp exp2 exp1 exp3 exp4)\<triangleright>\<^sub>r  (v:== exp1 ;; C2))"
  using 1 2 3 4
  by rel_auto

lemma assign_cond_qtop3[symbolic_exec_assign_qtop]:
  assumes 1: "weak_lens v" and 2: "v \<sharp> exp2" and 3: "v \<sharp> exp3" and 4: "v \<sharp> exp4"
  shows "(v:== exp1 ;; C1 \<triangleleft>(qtop bp exp2 exp3 (&v) exp4)\<triangleright>\<^sub>r C2) = 
         ((v:== exp1 ;; C1) \<triangleleft>(qtop bp exp2 exp3 exp1  exp4)\<triangleright>\<^sub>r (v:== exp1 ;; C2))"
  using 1 2 3 4
  by rel_auto

lemma assign_cond_qtop4[symbolic_exec_assign_qtop]:
  assumes 1: "weak_lens v" and 2: "v \<sharp> exp2" and 3: "v \<sharp> exp3" and 4: "v \<sharp> exp4"
  shows "(v:== exp1 ;; C1 \<triangleleft>(qtop bp exp2 exp3 exp4 (&v))\<triangleright>\<^sub>r C2) = 
         ((v:== exp1 ;; C1) \<triangleleft>(qtop bp exp2 exp3  exp4 exp1)\<triangleright>\<^sub>r (v:== exp1 ;; C2))"
  using 1 2 3 4
  by rel_auto

lemma assign_cond_If [symbolic_exec]:
  "((v:== exp1) \<triangleleft> bexp\<triangleright>\<^sub>r (v:== exp2)) = 
   (v :== (trop If bexp exp1 exp2))" 
  by rel_auto

lemma assign_cond_If_uop[symbolic_exec_assign_uop]:
  assumes 1: "mwb_lens v"
  shows "(v:== E;; 
         (v:== uop F (&v)) \<triangleleft>uop F (&v)\<triangleright>\<^sub>r (v:== uop G (&v))) =
         (v:== trop If (uop F E) (uop F E) (uop G E))" 
  using 1
proof (rel_simp, transfer)
  fix a :: 'a and b :: 'a and va :: "bool \<Longrightarrow> 'a" and Fa :: "bool \<Rightarrow> bool" and Ea :: "'a \<Rightarrow> bool" and Ga :: "bool \<Rightarrow> bool"
  have "Fa (Ea a) \<longrightarrow> (Fa (Ea a) \<and> b = put\<^bsub>va\<^esub> a (Fa (Ea a)) \<or> \<not> Fa (Ea a) \<and> b = put\<^bsub>va\<^esub> a (Ga (Ea a))) \<and> b = put\<^bsub>va\<^esub> a (Fa (Ea a) \<or> \<not> Fa (Ea a) \<and> Ga (Ea a)) \<or> \<not> b = put\<^bsub>va\<^esub> a (Fa (Ea a) \<or> \<not> Fa (Ea a) \<and> Ga (Ea a)) \<and> (\<not> Fa (Ea a) \<or> \<not> b = put\<^bsub>va\<^esub> a (Fa (Ea a)))"
    by presburger
  then have "\<not> ((\<not> Fa (Ea a) \<or> \<not> b = put\<^bsub>va\<^esub> a (Fa (Ea a))) \<and> (Fa (Ea a) \<or> \<not> b = put\<^bsub>va\<^esub> a (Ga (Ea a)))) = (b = put\<^bsub>va\<^esub> a (Fa (Ea a) \<or> \<not> Fa (Ea a) \<and> Ga (Ea a)))"
    by fastforce
  then show "(Fa (Ea a) \<and> b = put\<^bsub>va\<^esub> a (Fa (Ea a)) \<or> \<not> Fa (Ea a) \<and> b = put\<^bsub>va\<^esub> a (Ga (Ea a))) = (b = put\<^bsub>va\<^esub> a (Fa (Ea a) \<or> \<not> Fa (Ea a) \<and> Ga (Ea a)))"
    by meson
qed 

lemma assign_cond_If_bop[symbolic_exec_assign_bop]:
  assumes 1: "mwb_lens v" and 2:"v \<sharp> exp"
  shows "((v:== E);; 
          (v:== (bop F exp (&v))) \<triangleleft>bop F exp (&v)\<triangleright>\<^sub>r (v:== (bop G exp (&v)))) =
         (v:== (trop If (bop F exp E) (bop F exp E) (bop G exp E)))" 
  using 1 2
proof (rel_simp, transfer)
  fix a :: 'a and b :: 'a and va :: "bool \<Longrightarrow> 'a" and Fa :: "bool \<Rightarrow> bool" and Ea :: "'a \<Rightarrow> bool" and Ga :: "bool \<Rightarrow> bool"
  have "Fa (Ea a) \<longrightarrow> (Fa (Ea a) \<and> b = put\<^bsub>va\<^esub> a (Fa (Ea a)) \<or> \<not> Fa (Ea a) \<and> b = put\<^bsub>va\<^esub> a (Ga (Ea a))) \<and> b = put\<^bsub>va\<^esub> a (Fa (Ea a) \<or> \<not> Fa (Ea a) \<and> Ga (Ea a)) \<or> \<not> b = put\<^bsub>va\<^esub> a (Fa (Ea a) \<or> \<not> Fa (Ea a) \<and> Ga (Ea a)) \<and> (\<not> Fa (Ea a) \<or> \<not> b = put\<^bsub>va\<^esub> a (Fa (Ea a)))"
    by presburger
  then have "\<not> ((\<not> Fa (Ea a) \<or> \<not> b = put\<^bsub>va\<^esub> a (Fa (Ea a))) \<and> (Fa (Ea a) \<or> \<not> b = put\<^bsub>va\<^esub> a (Ga (Ea a)))) = (b = put\<^bsub>va\<^esub> a (Fa (Ea a) \<or> \<not> Fa (Ea a) \<and> Ga (Ea a)))"
    by fastforce
  then show "(Fa (Ea a) \<and> b = put\<^bsub>va\<^esub> a (Fa (Ea a)) \<or> \<not> Fa (Ea a) \<and> b = put\<^bsub>va\<^esub> a (Ga (Ea a))) = (b = put\<^bsub>va\<^esub> a (Fa (Ea a) \<or> \<not> Fa (Ea a) \<and> Ga (Ea a)))"
    by meson
qed 

lemma assign_cond_If_bop1[symbolic_exec_assign_bop]:
  assumes 1: "mwb_lens v" and 2:"v \<sharp> exp"
  shows "((v:== E);; 
          (v:== (bop F (&v) exp)) \<triangleleft>bop F (&v) exp\<triangleright>\<^sub>r (v:== (bop G (&v) exp))) =
         (v:== (trop If (bop F E exp) (bop F E exp) (bop G E exp)))" 
  using 1 2
proof (rel_simp, transfer)
  fix a :: 'a and b :: 'a and va :: "bool \<Longrightarrow> 'a" and Fa :: "bool \<Rightarrow> bool" and Ea :: "'a \<Rightarrow> bool" and Ga :: "bool \<Rightarrow> bool"
  have "Fa (Ea a) \<longrightarrow> (Fa (Ea a) \<and> b = put\<^bsub>va\<^esub> a (Fa (Ea a)) \<or> \<not> Fa (Ea a) \<and> b = put\<^bsub>va\<^esub> a (Ga (Ea a))) \<and> b = put\<^bsub>va\<^esub> a (Fa (Ea a) \<or> \<not> Fa (Ea a) \<and> Ga (Ea a)) \<or> \<not> b = put\<^bsub>va\<^esub> a (Fa (Ea a) \<or> \<not> Fa (Ea a) \<and> Ga (Ea a)) \<and> (\<not> Fa (Ea a) \<or> \<not> b = put\<^bsub>va\<^esub> a (Fa (Ea a)))"
    by presburger
  then have "\<not> ((\<not> Fa (Ea a) \<or> \<not> b = put\<^bsub>va\<^esub> a (Fa (Ea a))) \<and> (Fa (Ea a) \<or> \<not> b = put\<^bsub>va\<^esub> a (Ga (Ea a)))) = (b = put\<^bsub>va\<^esub> a (Fa (Ea a) \<or> \<not> Fa (Ea a) \<and> Ga (Ea a)))"
    by fastforce
  then show "(Fa (Ea a) \<and> b = put\<^bsub>va\<^esub> a (Fa (Ea a)) \<or> \<not> Fa (Ea a) \<and> b = put\<^bsub>va\<^esub> a (Ga (Ea a))) = (b = put\<^bsub>va\<^esub> a (Fa (Ea a) \<or> \<not> Fa (Ea a) \<and> Ga (Ea a)))"
    by meson
qed 

lemma assign_cond_If_bop2[symbolic_exec_assign_bop]:
  assumes 1: "mwb_lens v" and 2:"v \<sharp> exp1" and 3:"v \<sharp> exp2"
  shows "((v:== E);; 
          (v:== (bop F (&v) exp1)) \<triangleleft>bop F (&v) exp1\<triangleright>\<^sub>r (v:== (bop G (&v) exp2))) =
         (v:== (trop If (bop F E exp1) (bop F E exp1) (bop G E exp2)))" 
  using 1 2 3
proof (rel_simp, transfer)
  fix a :: 'a and b :: 'a and va :: "bool \<Longrightarrow> 'a" and Fa :: "bool \<Rightarrow> bool" and Ea :: "'a \<Rightarrow> bool" and Ga :: "bool \<Rightarrow> bool"
  have "Fa (Ea a) \<longrightarrow> (Fa (Ea a) \<and> b = put\<^bsub>va\<^esub> a (Fa (Ea a)) \<or> \<not> Fa (Ea a) \<and> b = put\<^bsub>va\<^esub> a (Ga (Ea a))) \<and> b = put\<^bsub>va\<^esub> a (Fa (Ea a) \<or> \<not> Fa (Ea a) \<and> Ga (Ea a)) \<or> \<not> b = put\<^bsub>va\<^esub> a (Fa (Ea a) \<or> \<not> Fa (Ea a) \<and> Ga (Ea a)) \<and> (\<not> Fa (Ea a) \<or> \<not> b = put\<^bsub>va\<^esub> a (Fa (Ea a)))"
    by presburger
  then have "\<not> ((\<not> Fa (Ea a) \<or> \<not> b = put\<^bsub>va\<^esub> a (Fa (Ea a))) \<and> (Fa (Ea a) \<or> \<not> b = put\<^bsub>va\<^esub> a (Ga (Ea a)))) = (b = put\<^bsub>va\<^esub> a (Fa (Ea a) \<or> \<not> Fa (Ea a) \<and> Ga (Ea a)))"
    by fastforce
  then show "(Fa (Ea a) \<and> b = put\<^bsub>va\<^esub> a (Fa (Ea a)) \<or> \<not> Fa (Ea a) \<and> b = put\<^bsub>va\<^esub> a (Ga (Ea a))) = (b = put\<^bsub>va\<^esub> a (Fa (Ea a) \<or> \<not> Fa (Ea a) \<and> Ga (Ea a)))"
    by meson
qed 

lemma assign_cond_If_bop4[symbolic_exec_assign_bop]:
  assumes 1: "mwb_lens v" and 2:"v \<sharp> exp1" and 3:"v \<sharp> exp2"
  shows "((v:== E);; 
          (v:== (bop F (&v) exp1)) \<triangleleft>bop F (&v) exp1\<triangleright>\<^sub>r (v:== (bop G exp2 (&v)))) =
         (v:== (trop If (bop F E exp1) (bop F E exp1) (bop G exp2 E)))" 
  using 1 2 3
proof (rel_simp, transfer)
  fix a :: 'a and b :: 'a and va :: "bool \<Longrightarrow> 'a" and Fa :: "bool \<Rightarrow> bool" and Ea :: "'a \<Rightarrow> bool" and Ga :: "bool \<Rightarrow> bool"
  have "Fa (Ea a) \<longrightarrow> (Fa (Ea a) \<and> b = put\<^bsub>va\<^esub> a (Fa (Ea a)) \<or> \<not> Fa (Ea a) \<and> b = put\<^bsub>va\<^esub> a (Ga (Ea a))) \<and> b = put\<^bsub>va\<^esub> a (Fa (Ea a) \<or> \<not> Fa (Ea a) \<and> Ga (Ea a)) \<or> \<not> b = put\<^bsub>va\<^esub> a (Fa (Ea a) \<or> \<not> Fa (Ea a) \<and> Ga (Ea a)) \<and> (\<not> Fa (Ea a) \<or> \<not> b = put\<^bsub>va\<^esub> a (Fa (Ea a)))"
    by presburger
  then have "\<not> ((\<not> Fa (Ea a) \<or> \<not> b = put\<^bsub>va\<^esub> a (Fa (Ea a))) \<and> (Fa (Ea a) \<or> \<not> b = put\<^bsub>va\<^esub> a (Ga (Ea a)))) = (b = put\<^bsub>va\<^esub> a (Fa (Ea a) \<or> \<not> Fa (Ea a) \<and> Ga (Ea a)))"
    by fastforce
  then show "(Fa (Ea a) \<and> b = put\<^bsub>va\<^esub> a (Fa (Ea a)) \<or> \<not> Fa (Ea a) \<and> b = put\<^bsub>va\<^esub> a (Ga (Ea a))) = (b = put\<^bsub>va\<^esub> a (Fa (Ea a) \<or> \<not> Fa (Ea a) \<and> Ga (Ea a)))"
    by meson
qed 

lemma assign_cond_If_bop5[symbolic_exec_assign_bop]:
  assumes 1: "mwb_lens v" and 2:"v \<sharp> exp1" and 3:"v \<sharp> exp2"
  shows "((v:== E);; 
          (v:== (bop F exp1 (&v))) \<triangleleft>bop F exp1 (&v)\<triangleright>\<^sub>r (v:== (bop G (&v) exp2))) =
         (v:== (trop If (bop F exp1 E) (bop F exp1 E) (bop G E exp2)))" 
  using 1 2 3
proof (rel_simp, transfer)
  fix a :: 'a and b :: 'a and va :: "bool \<Longrightarrow> 'a" and Fa :: "bool \<Rightarrow> bool" and Ea :: "'a \<Rightarrow> bool" and Ga :: "bool \<Rightarrow> bool"
  have "Fa (Ea a) \<longrightarrow> (Fa (Ea a) \<and> b = put\<^bsub>va\<^esub> a (Fa (Ea a)) \<or> \<not> Fa (Ea a) \<and> b = put\<^bsub>va\<^esub> a (Ga (Ea a))) \<and> b = put\<^bsub>va\<^esub> a (Fa (Ea a) \<or> \<not> Fa (Ea a) \<and> Ga (Ea a)) \<or> \<not> b = put\<^bsub>va\<^esub> a (Fa (Ea a) \<or> \<not> Fa (Ea a) \<and> Ga (Ea a)) \<and> (\<not> Fa (Ea a) \<or> \<not> b = put\<^bsub>va\<^esub> a (Fa (Ea a)))"
    by presburger
  then have "\<not> ((\<not> Fa (Ea a) \<or> \<not> b = put\<^bsub>va\<^esub> a (Fa (Ea a))) \<and> (Fa (Ea a) \<or> \<not> b = put\<^bsub>va\<^esub> a (Ga (Ea a)))) = (b = put\<^bsub>va\<^esub> a (Fa (Ea a) \<or> \<not> Fa (Ea a) \<and> Ga (Ea a)))"
    by fastforce
  then show "(Fa (Ea a) \<and> b = put\<^bsub>va\<^esub> a (Fa (Ea a)) \<or> \<not> Fa (Ea a) \<and> b = put\<^bsub>va\<^esub> a (Ga (Ea a))) = (b = put\<^bsub>va\<^esub> a (Fa (Ea a) \<or> \<not> Fa (Ea a) \<and> Ga (Ea a)))"
    by meson
qed 

lemma assign_cond_If_bop6[symbolic_exec_assign_bop]:
  assumes 1: "mwb_lens v" and 2:"v \<sharp> exp1" and 3:"v \<sharp> exp2"
  shows "((v:== E);; 
          (v:== (bop F exp1 (&v))) \<triangleleft>bop F exp1 (&v)\<triangleright>\<^sub>r (v:== (bop G exp2 (&v)))) =
         (v:== (trop If (bop F exp1 E) (bop F exp1 E) (bop G exp2 E)))" 
  using 1 2 3
proof (rel_simp, transfer)
  fix a :: 'a and b :: 'a and va :: "bool \<Longrightarrow> 'a" and Fa :: "bool \<Rightarrow> bool" and Ea :: "'a \<Rightarrow> bool" and Ga :: "bool \<Rightarrow> bool"
  have "Fa (Ea a) \<longrightarrow> (Fa (Ea a) \<and> b = put\<^bsub>va\<^esub> a (Fa (Ea a)) \<or> \<not> Fa (Ea a) \<and> b = put\<^bsub>va\<^esub> a (Ga (Ea a))) \<and> b = put\<^bsub>va\<^esub> a (Fa (Ea a) \<or> \<not> Fa (Ea a) \<and> Ga (Ea a)) \<or> \<not> b = put\<^bsub>va\<^esub> a (Fa (Ea a) \<or> \<not> Fa (Ea a) \<and> Ga (Ea a)) \<and> (\<not> Fa (Ea a) \<or> \<not> b = put\<^bsub>va\<^esub> a (Fa (Ea a)))"
    by presburger
  then have "\<not> ((\<not> Fa (Ea a) \<or> \<not> b = put\<^bsub>va\<^esub> a (Fa (Ea a))) \<and> (Fa (Ea a) \<or> \<not> b = put\<^bsub>va\<^esub> a (Ga (Ea a)))) = (b = put\<^bsub>va\<^esub> a (Fa (Ea a) \<or> \<not> Fa (Ea a) \<and> Ga (Ea a)))"
    by fastforce
  then show "(Fa (Ea a) \<and> b = put\<^bsub>va\<^esub> a (Fa (Ea a)) \<or> \<not> Fa (Ea a) \<and> b = put\<^bsub>va\<^esub> a (Ga (Ea a))) = (b = put\<^bsub>va\<^esub> a (Fa (Ea a) \<or> \<not> Fa (Ea a) \<and> Ga (Ea a)))"
    by meson
qed 

lemma assign_cond_If_trop[symbolic_exec_assign_trop]:
  assumes 1: "mwb_lens v" and 2:"v \<sharp> exp1" and 3:"v \<sharp> exp2"
  shows "((v:== E);;
         (v:== (trop F exp1 exp2 (&v))) \<triangleleft>trop F exp1 exp2 (&v)\<triangleright>\<^sub>r (v:== (trop G exp1 exp2 (&v)))) =
         (v:== (trop If (trop F exp1 exp2 E) (trop F exp1 exp2 E) (trop G exp1 exp2 E)))" 
  using 1 2 3
proof (rel_simp, transfer)
  fix a :: 'a and b :: 'a and va :: "bool \<Longrightarrow> 'a" and Fa :: "bool \<Rightarrow> bool" and Ea :: "'a \<Rightarrow> bool" and Ga :: "bool \<Rightarrow> bool"
  have "Fa (Ea a) \<longrightarrow> (Fa (Ea a) \<and> b = put\<^bsub>va\<^esub> a (Fa (Ea a)) \<or> \<not> Fa (Ea a) \<and> b = put\<^bsub>va\<^esub> a (Ga (Ea a))) \<and> b = put\<^bsub>va\<^esub> a (Fa (Ea a) \<or> \<not> Fa (Ea a) \<and> Ga (Ea a)) \<or> \<not> b = put\<^bsub>va\<^esub> a (Fa (Ea a) \<or> \<not> Fa (Ea a) \<and> Ga (Ea a)) \<and> (\<not> Fa (Ea a) \<or> \<not> b = put\<^bsub>va\<^esub> a (Fa (Ea a)))"
    by presburger
  then have "\<not> ((\<not> Fa (Ea a) \<or> \<not> b = put\<^bsub>va\<^esub> a (Fa (Ea a))) \<and> (Fa (Ea a) \<or> \<not> b = put\<^bsub>va\<^esub> a (Ga (Ea a)))) = (b = put\<^bsub>va\<^esub> a (Fa (Ea a) \<or> \<not> Fa (Ea a) \<and> Ga (Ea a)))"
    by fastforce
  then show "(Fa (Ea a) \<and> b = put\<^bsub>va\<^esub> a (Fa (Ea a)) \<or> \<not> Fa (Ea a) \<and> b = put\<^bsub>va\<^esub> a (Ga (Ea a))) = (b = put\<^bsub>va\<^esub> a (Fa (Ea a) \<or> \<not> Fa (Ea a) \<and> Ga (Ea a)))"
    by meson
qed 

lemma assign_cond_If_trop1[symbolic_exec_assign_trop]:
  assumes 1: "mwb_lens v" and 2:"v \<sharp> exp1" and 3:"v \<sharp> exp2"
  shows "((v:== E);; 
          (v:== (trop F exp1 (&v) exp2)) \<triangleleft>trop F exp1 (&v) exp2\<triangleright>\<^sub>r (v:== (trop G exp1 (&v) exp2))) =
         (v:== (trop If (trop F exp1 E exp2) (trop F exp1 E exp2) (trop G exp1 E exp2)))" 
  using 1 2 3
proof (rel_simp, transfer)
  fix a :: 'a and b :: 'a and va :: "bool \<Longrightarrow> 'a" and Fa :: "bool \<Rightarrow> bool" and Ea :: "'a \<Rightarrow> bool" and Ga :: "bool \<Rightarrow> bool"
  have "Fa (Ea a) \<longrightarrow> (Fa (Ea a) \<and> b = put\<^bsub>va\<^esub> a (Fa (Ea a)) \<or> \<not> Fa (Ea a) \<and> b = put\<^bsub>va\<^esub> a (Ga (Ea a))) \<and> b = put\<^bsub>va\<^esub> a (Fa (Ea a) \<or> \<not> Fa (Ea a) \<and> Ga (Ea a)) \<or> \<not> b = put\<^bsub>va\<^esub> a (Fa (Ea a) \<or> \<not> Fa (Ea a) \<and> Ga (Ea a)) \<and> (\<not> Fa (Ea a) \<or> \<not> b = put\<^bsub>va\<^esub> a (Fa (Ea a)))"
    by presburger
  then have "\<not> ((\<not> Fa (Ea a) \<or> \<not> b = put\<^bsub>va\<^esub> a (Fa (Ea a))) \<and> (Fa (Ea a) \<or> \<not> b = put\<^bsub>va\<^esub> a (Ga (Ea a)))) = (b = put\<^bsub>va\<^esub> a (Fa (Ea a) \<or> \<not> Fa (Ea a) \<and> Ga (Ea a)))"
    by fastforce
  then show "(Fa (Ea a) \<and> b = put\<^bsub>va\<^esub> a (Fa (Ea a)) \<or> \<not> Fa (Ea a) \<and> b = put\<^bsub>va\<^esub> a (Ga (Ea a))) = (b = put\<^bsub>va\<^esub> a (Fa (Ea a) \<or> \<not> Fa (Ea a) \<and> Ga (Ea a)))"
    by meson
qed 

lemma assign_cond_If_trop2[symbolic_exec_assign_trop]:
  assumes 1: "mwb_lens v" and 2:"v \<sharp> exp1" and 3:"v \<sharp> exp2"
  shows "((v:== E);; 
          (v:== (trop F (&v) exp1 exp2)) \<triangleleft>trop F (&v) exp1 exp2\<triangleright>\<^sub>r (v:== (trop G (&v) exp1 exp2))) =
         (v:== (trop If (trop F E exp1 exp2) (trop F E exp1 exp2) (trop G E exp1 exp2)))" 
  using 1 2 3
proof (rel_simp, transfer)
  fix a :: 'a and b :: 'a and va :: "bool \<Longrightarrow> 'a" and Fa :: "bool \<Rightarrow> bool" and Ea :: "'a \<Rightarrow> bool" and Ga :: "bool \<Rightarrow> bool"
  have "Fa (Ea a) \<longrightarrow> (Fa (Ea a) \<and> b = put\<^bsub>va\<^esub> a (Fa (Ea a)) \<or> \<not> Fa (Ea a) \<and> b = put\<^bsub>va\<^esub> a (Ga (Ea a))) \<and> b = put\<^bsub>va\<^esub> a (Fa (Ea a) \<or> \<not> Fa (Ea a) \<and> Ga (Ea a)) \<or> \<not> b = put\<^bsub>va\<^esub> a (Fa (Ea a) \<or> \<not> Fa (Ea a) \<and> Ga (Ea a)) \<and> (\<not> Fa (Ea a) \<or> \<not> b = put\<^bsub>va\<^esub> a (Fa (Ea a)))"
    by presburger
  then have "\<not> ((\<not> Fa (Ea a) \<or> \<not> b = put\<^bsub>va\<^esub> a (Fa (Ea a))) \<and> (Fa (Ea a) \<or> \<not> b = put\<^bsub>va\<^esub> a (Ga (Ea a)))) = (b = put\<^bsub>va\<^esub> a (Fa (Ea a) \<or> \<not> Fa (Ea a) \<and> Ga (Ea a)))"
    by fastforce
  then show "(Fa (Ea a) \<and> b = put\<^bsub>va\<^esub> a (Fa (Ea a)) \<or> \<not> Fa (Ea a) \<and> b = put\<^bsub>va\<^esub> a (Ga (Ea a))) = (b = put\<^bsub>va\<^esub> a (Fa (Ea a) \<or> \<not> Fa (Ea a) \<and> Ga (Ea a)))"
    by meson
qed 

lemma assign_cond_If_trop3[symbolic_exec_assign_trop]:
  assumes 1: "mwb_lens v" and 2:"v \<sharp> exp1" and 3:"v \<sharp> exp2" and 4:"v \<sharp> exp3" and 5:"v \<sharp> exp4"
  shows "((v:== E);;
          (v:== (trop F exp1 exp2 (&v))) \<triangleleft>trop F exp1 exp2 (&v)\<triangleright>\<^sub>r (v:== (trop G exp3 exp4 (&v)))) =
         (v:== (trop If (trop F exp1 exp2 E) (trop F exp1 exp2 E) (trop G exp3 exp4 E)))" 
  using 1 2 3 4 5
proof (rel_simp, transfer)
  fix a :: 'a and b :: 'a and va :: "bool \<Longrightarrow> 'a" and Fa :: "bool \<Rightarrow> bool" and Ea :: "'a \<Rightarrow> bool" and Ga :: "bool \<Rightarrow> bool"
  have "Fa (Ea a) \<longrightarrow> (Fa (Ea a) \<and> b = put\<^bsub>va\<^esub> a (Fa (Ea a)) \<or> \<not> Fa (Ea a) \<and> b = put\<^bsub>va\<^esub> a (Ga (Ea a))) \<and> b = put\<^bsub>va\<^esub> a (Fa (Ea a) \<or> \<not> Fa (Ea a) \<and> Ga (Ea a)) \<or> \<not> b = put\<^bsub>va\<^esub> a (Fa (Ea a) \<or> \<not> Fa (Ea a) \<and> Ga (Ea a)) \<and> (\<not> Fa (Ea a) \<or> \<not> b = put\<^bsub>va\<^esub> a (Fa (Ea a)))"
    by presburger
  then have "\<not> ((\<not> Fa (Ea a) \<or> \<not> b = put\<^bsub>va\<^esub> a (Fa (Ea a))) \<and> (Fa (Ea a) \<or> \<not> b = put\<^bsub>va\<^esub> a (Ga (Ea a)))) = (b = put\<^bsub>va\<^esub> a (Fa (Ea a) \<or> \<not> Fa (Ea a) \<and> Ga (Ea a)))"
    by fastforce
  then show "(Fa (Ea a) \<and> b = put\<^bsub>va\<^esub> a (Fa (Ea a)) \<or> \<not> Fa (Ea a) \<and> b = put\<^bsub>va\<^esub> a (Ga (Ea a))) = (b = put\<^bsub>va\<^esub> a (Fa (Ea a) \<or> \<not> Fa (Ea a) \<and> Ga (Ea a)))"
    by meson
qed 

lemma assign_cond_If_trop4[symbolic_exec_assign_trop]:
  assumes 1: "mwb_lens v" and 2:"v \<sharp> exp1" and 3:"v \<sharp> exp2" and 4:"v \<sharp> exp3" and 5:"v \<sharp> exp4"
  shows "((v:== E);; 
         (v:== (trop F exp1 (&v) exp2)) \<triangleleft>trop F exp1 (&v) exp2\<triangleright>\<^sub>r (v:== (trop G exp3 (&v) exp4))) =
         (v:== (trop If (trop F exp1 E exp2) (trop F exp1 E exp2) (trop G exp3 E exp4)))" 
  using 1 2 3 4 5
proof (rel_simp, transfer)
  fix a :: 'a and b :: 'a and va :: "bool \<Longrightarrow> 'a" and Fa :: "bool \<Rightarrow> bool" and Ea :: "'a \<Rightarrow> bool" and Ga :: "bool \<Rightarrow> bool"
  have "Fa (Ea a) \<longrightarrow> (Fa (Ea a) \<and> b = put\<^bsub>va\<^esub> a (Fa (Ea a)) \<or> \<not> Fa (Ea a) \<and> b = put\<^bsub>va\<^esub> a (Ga (Ea a))) \<and> b = put\<^bsub>va\<^esub> a (Fa (Ea a) \<or> \<not> Fa (Ea a) \<and> Ga (Ea a)) \<or> \<not> b = put\<^bsub>va\<^esub> a (Fa (Ea a) \<or> \<not> Fa (Ea a) \<and> Ga (Ea a)) \<and> (\<not> Fa (Ea a) \<or> \<not> b = put\<^bsub>va\<^esub> a (Fa (Ea a)))"
    by presburger
  then have "\<not> ((\<not> Fa (Ea a) \<or> \<not> b = put\<^bsub>va\<^esub> a (Fa (Ea a))) \<and> (Fa (Ea a) \<or> \<not> b = put\<^bsub>va\<^esub> a (Ga (Ea a)))) = (b = put\<^bsub>va\<^esub> a (Fa (Ea a) \<or> \<not> Fa (Ea a) \<and> Ga (Ea a)))"
    by fastforce
  then show "(Fa (Ea a) \<and> b = put\<^bsub>va\<^esub> a (Fa (Ea a)) \<or> \<not> Fa (Ea a) \<and> b = put\<^bsub>va\<^esub> a (Ga (Ea a))) = (b = put\<^bsub>va\<^esub> a (Fa (Ea a) \<or> \<not> Fa (Ea a) \<and> Ga (Ea a)))"
    by meson
qed 

lemma assign_cond_If_trop5[symbolic_exec_assign_trop]:
  assumes 1: "mwb_lens v" and 2:"v \<sharp> exp1" and 3:"v \<sharp> exp2" and 4:"v \<sharp> exp3" and 5:"v \<sharp> exp4"
  shows "((v:== E);; 
          (v:== (trop F (&v) exp1 exp2)) \<triangleleft>trop F (&v) exp1 exp2\<triangleright>\<^sub>r (v:== (trop G (&v) exp3 exp4))) =
         (v:== (trop If (trop F E exp1 exp2) (trop F E exp1 exp2) (trop G E exp3 exp4)))" 
  using 1 2 3 4 5
proof (rel_simp, transfer)
  fix a :: 'a and b :: 'a and va :: "bool \<Longrightarrow> 'a" and Fa :: "bool \<Rightarrow> bool" and Ea :: "'a \<Rightarrow> bool" and Ga :: "bool \<Rightarrow> bool"
  have "Fa (Ea a) \<longrightarrow> (Fa (Ea a) \<and> b = put\<^bsub>va\<^esub> a (Fa (Ea a)) \<or> \<not> Fa (Ea a) \<and> b = put\<^bsub>va\<^esub> a (Ga (Ea a))) \<and> b = put\<^bsub>va\<^esub> a (Fa (Ea a) \<or> \<not> Fa (Ea a) \<and> Ga (Ea a)) \<or> \<not> b = put\<^bsub>va\<^esub> a (Fa (Ea a) \<or> \<not> Fa (Ea a) \<and> Ga (Ea a)) \<and> (\<not> Fa (Ea a) \<or> \<not> b = put\<^bsub>va\<^esub> a (Fa (Ea a)))"
    by presburger
  then have "\<not> ((\<not> Fa (Ea a) \<or> \<not> b = put\<^bsub>va\<^esub> a (Fa (Ea a))) \<and> (Fa (Ea a) \<or> \<not> b = put\<^bsub>va\<^esub> a (Ga (Ea a)))) = (b = put\<^bsub>va\<^esub> a (Fa (Ea a) \<or> \<not> Fa (Ea a) \<and> Ga (Ea a)))"
    by fastforce
  then show "(Fa (Ea a) \<and> b = put\<^bsub>va\<^esub> a (Fa (Ea a)) \<or> \<not> Fa (Ea a) \<and> b = put\<^bsub>va\<^esub> a (Ga (Ea a))) = (b = put\<^bsub>va\<^esub> a (Fa (Ea a) \<or> \<not> Fa (Ea a) \<and> Ga (Ea a)))"
    by meson
qed 

subsection {*Conditional Laws*}
text{*In this section we introduce the algebraic laws of programming related to the conditional
      statement.*}

lemma cond_idem[symbolic_exec]:
  "(P \<triangleleft> b \<triangleright> P) = P" 
  by rel_auto

lemma cond_symm:
  "(P \<triangleleft> b \<triangleright> Q) = (Q \<triangleleft>\<not> b\<triangleright> P)" 
  by rel_auto

lemma cond_assoc: 
  "(P \<triangleleft> b \<triangleright> (Q \<triangleleft> b \<triangleright> R)) = ((P \<triangleleft> b \<triangleright> Q) \<triangleleft> b \<triangleright>  R)"  
  by rel_auto

lemma cond_distr[symbolic_exec]: 
  "((P \<triangleleft> b'\<triangleright> R) \<triangleleft> b \<triangleright> (Q \<triangleleft> b'\<triangleright> R))= ((P \<triangleleft> b \<triangleright> Q) \<triangleleft> b'\<triangleright> R)" 
  by rel_auto

lemma cond_unit_T [symbolic_exec_ex]:
  "(P \<triangleleft>true\<triangleright> Q) = P" 
  by auto

lemma cond_unit_F [symbolic_exec_ex]:
  "(P \<triangleleft>false\<triangleright> Q) = Q" 
  by auto

lemma cond_and_T_integrate[symbolic_exec]:
  "((P \<and> b) \<or> (Q \<triangleleft> b \<triangleright> R)) = ((P \<or> Q) \<triangleleft> b \<triangleright> R)"
  by rel_auto

lemma cond_L6[symbolic_exec]: 
  "(P \<triangleleft> b \<triangleright> (Q \<triangleleft> b \<triangleright> R)) = (P \<triangleleft> b \<triangleright> R)" 
  by rel_auto

lemma cond_L7[symbolic_exec]: 
  "(P \<triangleleft> b \<triangleright> (P \<triangleleft> c \<triangleright> Q)) = (P \<triangleleft> b \<or> c \<triangleright> Q)"
  by rel_auto

lemma cond_and_distr[symbolic_exec]: 
  "((P \<and> Q) \<triangleleft> b \<triangleright> (R \<and> S)) = ((P \<triangleleft> b \<triangleright> R) \<and> (Q \<triangleleft> b \<triangleright> S))"  
  by rel_auto

lemma cond_or_distr[symbolic_exec]: 
  "((P \<or> Q) \<triangleleft> b \<triangleright> (R \<or> S)) = ((P \<triangleleft> b \<triangleright> R) \<or> (Q \<triangleleft> b \<triangleright> S))" 
  by rel_auto

lemma cond_imp_distr[symbolic_exec]:
  "((P \<Rightarrow> Q) \<triangleleft> b \<triangleright> (R \<Rightarrow> S)) = 
   ((P \<triangleleft> b \<triangleright> R) \<Rightarrow> (Q \<triangleleft> b \<triangleright> S))" 
  by rel_auto

lemma cond_eq_distr[symbolic_exec]:
  "((P \<Leftrightarrow> Q) \<triangleleft> b \<triangleright> (R \<Leftrightarrow> S)) = 
   ((P \<triangleleft> b \<triangleright> R) \<Leftrightarrow> (Q \<triangleleft> b \<triangleright> S))"
  by rel_auto

lemma cond_conj_distr[symbolic_exec]:
  "(P \<and> (Q \<triangleleft> b \<triangleright> S)) = ((P \<and> Q) \<triangleleft> b \<triangleright> (P \<and> S))"  
  by rel_auto

lemma cond_disj_distr [symbolic_exec]:
  "(P \<or> (Q \<triangleleft> b \<triangleright> S)) = ((P \<or> Q) \<triangleleft> b \<triangleright> (P \<or> S))" 
  by rel_auto 

lemma cond_neg[symbolic_exec]: 
  "\<not> (P \<triangleleft> b \<triangleright> Q) = ((\<not> P) \<triangleleft> b \<triangleright> (\<not> Q))"
  by rel_auto 

lemma cond_conj[symbolic_exec]: 
  "(P \<triangleleft>b \<and> c\<triangleright> Q) = (P \<triangleleft> c \<triangleright> Q) \<triangleleft> b \<triangleright> Q"
  by rel_auto 
    
(*IF Theorem by Hoare: It optimize nested IF*)
theorem COND12[symbolic_exec]: 
  "((C1 \<triangleleft>bexp2\<triangleright> C3) \<triangleleft>bexp1\<triangleright> (C2 \<triangleleft>bexp3\<triangleright> C3)) =
   ((C1 \<triangleleft>bexp1\<triangleright> C2) \<triangleleft>(bexp2 \<triangleleft>bexp1\<triangleright>bexp3)\<triangleright> C3)"
  by rel_auto 
 
lemma comp_cond_left_distr:
  "((P \<triangleleft> b \<triangleright>\<^sub>r Q) ;; R) = ((P ;; R) \<triangleleft> b \<triangleright>\<^sub>r (Q ;; R))"
  by rel_auto
 
lemma cond_var_subst_left:
  assumes "vwb_lens x"
  shows "(P\<lbrakk>true/x\<rbrakk> \<triangleleft>&x \<triangleright> Q) = (P \<triangleleft>&x \<triangleright> Q)"
  using assms
  apply rel_auto apply transfer
  using vwb_lens.put_eq by fastforce 

lemma cond_var_subst_right:
  assumes "vwb_lens x"
  shows "(P \<triangleleft>&x \<triangleright> Q\<lbrakk>false/x\<rbrakk>) = (P \<triangleleft>&x \<triangleright> Q)"
  using assms
  apply rel_auto apply transfer
  by (metis (full_types) vwb_lens.put_eq)

lemma cond_var_split:
  "vwb_lens x \<Longrightarrow> (P\<lbrakk>true/x\<rbrakk> \<triangleleft>&x \<triangleright> P\<lbrakk>false/x\<rbrakk>) = P"
  by (rel_auto, (metis (full_types) vwb_lens.put_eq)+)

lemma cond_seq_left_distr:
  "out\<alpha> \<sharp> b \<Longrightarrow> ((P \<triangleleft> b \<triangleright> Q) ;; R) = ((P ;; R) \<triangleleft> b \<triangleright> (Q ;; R))"
  by rel_auto

lemma cond_seq_right_distr:
  "in\<alpha> \<sharp> b \<Longrightarrow> (P ;; (Q \<triangleleft> b \<triangleright> R)) = ((P ;; Q) \<triangleleft> b \<triangleright> (P ;; R))"
  by rel_auto

subsection {*Sequential Laws*}
text{*In this section we introduce the algebraic laws of programming related to the sequential
      composition of statements.*}


lemma seqr_exists_left[symbolic_exec]: 
  "((\<exists> $x \<bullet> P) ;; Q) = (\<exists> $x \<bullet> (P ;; Q))"
  by rel_auto

lemma seqr_exists_right[symbolic_exec]:
  "(P ;; (\<exists> $x\<acute> \<bullet> Q)) = (\<exists> $x\<acute> \<bullet> (P ;; Q))"
  by rel_auto

lemma seqr_left_zero [simp, symbolic_exec_ex]:
  "false ;; P = false"
  by pred_auto

lemma seqr_right_zero [simp, symbolic_exec_ex]:
  "P ;; false = false"
  by pred_auto

lemma seqr_assoc: "P ;; (Q ;; R) = (P ;; Q) ;; R"
  by rel_auto

lemma seqr_or_distl:
  "((P \<or> Q) ;; R) = ((P ;; R) \<or> (Q ;; R))"
  by rel_auto

lemma seqr_or_distr:
  "(P ;; (Q \<or> R)) = ((P ;; Q) \<or> (P ;; R))"
  by rel_auto

lemma seqr_unfold:
  "(P ;; Q) = (\<^bold>\<exists> v \<bullet> P\<lbrakk>\<guillemotleft>v\<guillemotright>/$\<Sigma>\<acute>\<rbrakk> \<and> Q\<lbrakk>\<guillemotleft>v\<guillemotright>/$\<Sigma>\<rbrakk>)"
  by rel_auto

lemma seqr_middle:
  assumes "vwb_lens x"
  shows "(P ;; Q) = (\<^bold>\<exists> v \<bullet> P\<lbrakk>\<guillemotleft>v\<guillemotright>/$x\<acute>\<rbrakk> ;; Q\<lbrakk>\<guillemotleft>v\<guillemotright>/$x\<rbrakk>)"
  using assms
  apply (rel_auto robust)
  apply (rename_tac xa P Q a b y)
  apply (rule_tac x="get\<^bsub>xa\<^esub> y" in exI)
  apply (rule_tac x="y" in exI)
  apply (simp)
done

lemma seqr_left_one_point:
  assumes "vwb_lens x"
  shows "((P \<and> $x\<acute> =\<^sub>u \<guillemotleft>v\<guillemotright>) ;; Q) = (P\<lbrakk>\<guillemotleft>v\<guillemotright>/$x\<acute>\<rbrakk> ;; Q\<lbrakk>\<guillemotleft>v\<guillemotright>/$x\<rbrakk>)"
  using assms
  by (rel_auto, metis vwb_lens_wb wb_lens.get_put)

lemma seqr_right_one_point:
  assumes "vwb_lens x"
  shows "(P ;; ($x =\<^sub>u \<guillemotleft>v\<guillemotright> \<and> Q)) = (P\<lbrakk>\<guillemotleft>v\<guillemotright>/$x\<acute>\<rbrakk> ;; Q\<lbrakk>\<guillemotleft>v\<guillemotright>/$x\<rbrakk>)"
  using assms
  by (rel_auto, metis vwb_lens_wb wb_lens.get_put)

lemma seqr_insert_ident_left:
  assumes "vwb_lens x" "$x\<acute> \<sharp> P" "$x \<sharp> Q"
  shows "(($x\<acute> =\<^sub>u $x \<and> P) ;; Q) = (P ;; Q)"
  using assms
  by (rel_auto, meson vwb_lens_wb wb_lens_weak weak_lens.put_get)

lemma seqr_insert_ident_right:
  assumes "vwb_lens x" "$x\<acute> \<sharp> P" "$x \<sharp> Q"
  shows "(P ;; ($x\<acute> =\<^sub>u $x \<and> Q)) = (P ;; Q)"
  using assms
  by (rel_auto, metis (no_types, hide_lams) vwb_lens_def wb_lens_def weak_lens.put_get)

lemma seq_var_ident_lift:
  assumes "vwb_lens x" "$x\<acute> \<sharp> P" "$x \<sharp> Q"
  shows "(($x\<acute> =\<^sub>u $x \<and> P) ;; ($x\<acute> =\<^sub>u $x \<and> Q)) = ($x\<acute> =\<^sub>u $x \<and> (P ;; Q))"
  using assms
  by (rel_auto, metis (no_types, lifting) vwb_lens_wb wb_lens_weak weak_lens.put_get)

lemma seqr_skip: "II ;; C = C ;; II"
  by (metis seqr_left_unit seqr_right_unit)

(*The rules SEQ6 SEQ7 related to SEQ and non-deterministic choice are missing for now*)
  
subsection {*While laws*}
text{*In this section we introduce the algebraic laws of programming related to the while
      statement.*}

theorem while_unfold:
  "while b do P od = ((P ;; while b do P od) \<triangleleft> b \<triangleright>\<^sub>r II)"
proof -
  have m:"mono (\<lambda>X. (P ;; X) \<triangleleft> b \<triangleright>\<^sub>r II)"
    by (auto intro: monoI seqr_mono cond_mono)
  have "(while b do P od) = (\<nu> X \<bullet> (P ;; X) \<triangleleft> b \<triangleright>\<^sub>r II)"
    by (simp add: while_def)
  also have "... = ((P ;; (\<nu> X \<bullet> (P ;; X) \<triangleleft> b \<triangleright>\<^sub>r II)) \<triangleleft> b \<triangleright>\<^sub>r II)"
    by (subst lfp_unfold, simp_all add: m)
  also have "... = ((P ;; while b do P od) \<triangleleft> b \<triangleright>\<^sub>r II)"
    by (simp add: while_def)
  finally show ?thesis .
qed

lemma while_true:
  shows "(while true do P od) = false"
  apply (simp add: while_def alpha)
  apply (rule antisym)
  apply (simp_all)
  apply (rule lfp_lowerbound)
  apply (simp)
done

lemma while_false:
  shows "(while false do P od) = II"
proof -
  have "(while false do P od) = (P ;; while false do P od) \<triangleleft> false \<triangleright>\<^sub>r II" 
    using while_unfold[of _ P] by simp
  also have "... = II" by (simp add: aext_false)
  finally show ?thesis . 
qed

lemma while_inv_unfold:
  "while b invr p do P od = ((P ;; while b invr p do P od) \<triangleleft> b \<triangleright>\<^sub>r II)"
  unfolding while_inv_def using while_unfold
  by auto

theorem while_bot_unfold:
  "while\<^sub>\<bottom> b do P od = ((P ;; while\<^sub>\<bottom> b do P od) \<triangleleft> b \<triangleright>\<^sub>r II)"
proof -
  have m:"mono (\<lambda>X. (P ;; X) \<triangleleft> b \<triangleright>\<^sub>r II)"
    by (auto intro: monoI seqr_mono cond_mono)
  have "(while\<^sub>\<bottom> b do P od) = (\<mu> X \<bullet> (P ;; X) \<triangleleft> b \<triangleright>\<^sub>r II)"
    by (simp add: while_bot_def)
  also have "... = ((P ;; (\<mu> X \<bullet> (P ;; X) \<triangleleft> b \<triangleright>\<^sub>r II)) \<triangleleft> b \<triangleright>\<^sub>r II)"
    by (subst gfp_unfold, simp_all add: m)
  also have "... = ((P ;; while\<^sub>\<bottom> b do P od) \<triangleleft> b \<triangleright>\<^sub>r II)"
    by (simp add: while_bot_def)
  finally show ?thesis .
qed

theorem while_bot_false: "while\<^sub>\<bottom> false do P od = II"
  by (simp add: while_bot_def mu_const alpha)

theorem while_bot_true: "while\<^sub>\<bottom> true do P od = (\<mu> X \<bullet> P ;; X)"
  by (simp add: while_bot_def alpha)

text {* An infinite loop with a feasible body corresponds to a program error (non-termination). *}

theorem while_infinite: "P ;; true\<^sub>h = true \<Longrightarrow> while\<^sub>\<bottom> true do P od = true"
  apply (simp add: while_bot_true)
  apply (rule antisym)
  apply (simp)
  apply (rule gfp_upperbound)
  apply (simp)
done

subsection {*assume and assert laws*}

lemma assume_twice: "(b\<^sup>\<top> ;; c\<^sup>\<top>) = (b \<and> c)\<^sup>\<top>"
  by rel_auto

lemma assert_twice: "(b\<^sub>\<bottom> ;; c\<^sub>\<bottom>) = (b \<and> c)\<^sub>\<bottom>" 
  by rel_auto

subsection {* Relation algebra laws *}

theorem RA1: "(P ;; (Q ;; R)) = ((P ;; Q) ;; R)"
  using seqr_assoc by auto

theorem RA2: "(P ;; II) = P" "(II ;; P) = P"
  by simp_all

theorem RA3: "P\<^sup>-\<^sup>- = P"
  by simp

theorem RA4: "(P ;; Q)\<^sup>- = (Q\<^sup>- ;; P\<^sup>-)"
  by simp

theorem RA5: "(P \<or> Q)\<^sup>- = (P\<^sup>- \<or> Q\<^sup>-)"
  by (rel_auto)

theorem RA6: "((P \<or> Q) ;; R) = ((P;;R) \<or> (Q;;R))"
  using seqr_or_distl by blast

theorem RA7: "((P\<^sup>- ;; (\<not>(P ;; Q))) \<or> (\<not>Q)) = (\<not>Q)"
  by (rel_auto)

subsection {* Relational alphabet extension *}

lift_definition rel_alpha_ext :: "'\<beta> hrel \<Rightarrow> ('\<beta> \<Longrightarrow> '\<alpha>) \<Rightarrow> '\<alpha> hrel" (infix "\<oplus>\<^sub>R" 65)
is "\<lambda> P x (b1, b2). P (get\<^bsub>x\<^esub> b1, get\<^bsub>x\<^esub> b2) \<and> (\<forall> b. b1 \<oplus>\<^sub>L b on x = b2 \<oplus>\<^sub>L b on x)" .

lemma rel_alpha_ext_alt_def:
  assumes "vwb_lens y" "x +\<^sub>L y \<approx>\<^sub>L 1\<^sub>L" "x \<bowtie> y"
  shows "P \<oplus>\<^sub>R x = (P \<oplus>\<^sub>p (x \<times>\<^sub>L x) \<and> $y\<acute> =\<^sub>u $y)"
  using assms
  apply (rel_auto robust, simp_all add: lens_override_def)
  apply (metis lens_indep_get lens_indep_sym)
  apply (metis vwb_lens_def wb_lens.get_put wb_lens_def weak_lens.put_get)
done


subsection {*Tactic setup*}
text {*In this section we will design a tactic that can be used to automate
       the process of program optimization.*}
(*TODO*)

end