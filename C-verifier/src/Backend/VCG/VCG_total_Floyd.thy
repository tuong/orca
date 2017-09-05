section \<open>VCG for total correctness using Floyd assignment\<close>

theory VCG_total_Floyd
  imports "../../Midend-IVL/Isabelle-UTP-Extended/hoare/HoareLogic/TotalCorrectness/Abrupt/utp_hoare_total"
begin

text \<open>The below definition helps in asserting independence for a group of lenses, as otherwise the
number of assumptions required increases greatly.\<close>
definition \<open>lens_indep_all lenses \<equiv>
  distinct lenses \<and> (\<forall>a \<in> set lenses. \<forall>b \<in> set lenses. a \<noteq> b \<longrightarrow> a \<bowtie> b)\<close>

lemma assert_hoare_r_t':
  assumes \<open>`p \<Rightarrow> c`\<close>
  shows \<open>\<lbrace>p\<rbrace>c\<^sub>\<bottom>\<^sub>C\<lbrace>p \<and> c\<rbrace>\<^sub>A\<^sub>B\<^sub>R\<close>
  by (metis assms cond_abr_hoare_r_t hoare_false_t neg_conj_cancel1 p_and_not_p rassert_abr_def
skip_abr_hoare_r_t subsumption1 utp_pred.inf_commute utp_pred.sup_commute)

lemma assume_hoare_r_t': 
  shows \<open>\<lbrace>p\<rbrace>c\<^sup>\<top>\<^sup>C\<lbrace>p \<and> c\<rbrace>\<^sub>A\<^sub>B\<^sub>R\<close>
  by rel_simp

lemma cond_abr_hoare_r_t': 
  assumes \<open>\<lbrace>b \<and> p\<rbrace>C\<^sub>1\<lbrace>q\<rbrace>\<^sub>A\<^sub>B\<^sub>R\<close> and \<open>\<lbrace>\<not>b \<and> p\<rbrace>C\<^sub>2\<lbrace>s\<rbrace>\<^sub>A\<^sub>B\<^sub>R\<close>
  shows \<open>\<lbrace>p\<rbrace>bif b then C\<^sub>1 else C\<^sub>2 eif\<lbrace>q \<or> s\<rbrace>\<^sub>A\<^sub>B\<^sub>R\<close>
  by (insert assms, rel_auto) metis+ 

lemma cond_assert_abr_hoare_r_t:
  assumes \<open>\<lbrace>b \<and> p\<rbrace>C\<^sub>1\<lbrace>q\<rbrace>\<^sub>A\<^sub>B\<^sub>R\<close>
      and \<open>\<lbrace>\<not>b \<and> p\<rbrace>C\<^sub>2\<lbrace>s\<rbrace>\<^sub>A\<^sub>B\<^sub>R\<close>
      and \<open>`q \<Rightarrow> A`\<close>
      and \<open>`s \<Rightarrow> A`\<close>
      and \<open>\<lbrace>A\<rbrace>P\<lbrace>A'\<rbrace>\<^sub>A\<^sub>B\<^sub>R\<close>
    shows \<open>\<lbrace>p\<rbrace>bif b then C\<^sub>1 else C\<^sub>2 eif;; A\<^sub>\<bottom>\<^sub>C;; P\<lbrace>A'\<rbrace>\<^sub>A\<^sub>B\<^sub>R\<close>
  apply (insert assms)
  apply (rule hoare_post_weak_t)
   apply (rule cond_abr_hoare_r_t' seq_hoare_r_t|assumption)+
    apply (rule assert_hoare_r_t')
    apply (metis impl_alt_def subsumption1 utp_pred.double_compl utp_pred.sup_assoc utp_pred.sup_compl_top_left2)
   apply (rule hoare_pre_str_t[where p\<^sub>2 = A])
    apply (simp add: impl_alt_def utp_pred.sup_commute)
   apply assumption
  by simp

lemma while_invr_hoare_r_t':
  assumes \<open>`pre \<Rightarrow> p`\<close> and \<open>\<lbrace>p \<and> b\<rbrace>C\<lbrace>p'\<rbrace>\<^sub>A\<^sub>B\<^sub>R\<close> and \<open>`p' \<Rightarrow> p`\<close>
  shows \<open>\<lbrace>pre\<rbrace>while b invr p do C od\<lbrace>\<not>b \<and> p\<rbrace>\<^sub>A\<^sub>B\<^sub>R\<close>
  by (metis While_inv_def assms hoare_post_weak_t hoare_pre_str_t while_hoare_r_t)

lemmas hoare_rules =
  assigns_abr_floyd_r_t
  skip_abr_hoare_r_t
  assert_hoare_r_t'
  assume_hoare_r_t'
  cond_assert_abr_hoare_r_t (* Needs some heuristics *)
  seq_hoare_r_t
  cond_abr_hoare_r_t'
  while_invr_hoare_r_t'

lemmas extra_simps = 
  lens_indep.lens_put_irr1
  lens_indep.lens_put_irr2
  lens_indep_all_def

method solve_vcg = assumption|(pred_simp; (simp add: extra_simps)?)
method exp_vcg_step = rule hoare_rules|(solve_vcg; fail)
method exp_vcg =
  (simp only: seqr_assoc[symmetric])?,
  rule hoare_post_weak_t,
  exp_vcg_step+

end
