section{*Hoare Logic*}

theory Hoare
imports Algebraic_Laws

begin

subsection {*Examples*}

text {*In this section we introduce small examples showing how can use the tools from the lens 
       theory to represent a Hoare triple*}

named_theorems hoare_partial

lemma Hoare_test1:
  assumes 1:"weak_lens Y"
  shows"\<lceil>(VAR X) =\<^sub>e \<guillemotleft>1::int\<guillemotright> \<longrightarrow>\<^sub>e (Y :== (VAR X)) \<dagger> (VAR Y) =\<^sub>e \<guillemotleft>1::int\<guillemotright>\<rceil>"
  using 1 unfolding subst_upd_var_def
  by transfer auto

lemma Hoare_test2:
  assumes 1:"weak_lens Y" and 2:"X \<bowtie> Y"
  shows"\<lceil>(VAR X) =\<^sub>e \<guillemotleft>1::int\<guillemotright> \<longrightarrow>\<^sub>e (Y :== (VAR X))\<dagger> (VAR Y) =\<^sub>e \<guillemotleft>2::int\<guillemotright>\<rceil> "
  using 1 2 unfolding subst_upd_var_def lens_indep_def
  apply transfer 
  apply auto oops

lemma Hoare_test3:
  assumes 1:"vwb_lens Y" and  2:"vwb_lens X" and 3:"vwb_lens R"
  and     4:"X \<bowtie> Y"     and  5:"X \<bowtie> R"     and 6:"Y\<bowtie> R"
  shows "\<lceil>(VAR X) =\<^sub>e \<guillemotleft>1::int\<guillemotright> \<and>\<^sub>e (VAR Y) =\<^sub>e \<guillemotleft>2::int\<guillemotright> \<longrightarrow>\<^sub>e
          (R:== (VAR X) ; X :== (VAR Y); Y:== (VAR R))\<dagger>((VAR X) =\<^sub>e \<guillemotleft>2::int\<guillemotright> \<and>\<^sub>e (VAR Y) =\<^sub>e \<guillemotleft>1::int\<guillemotright>)\<rceil>"
  using assms unfolding subst_upd_var_def id_def lens_indep_def 
  by transfer auto 

lemma Hoare_test4:
  assumes 1:"weak_lens Y" and 2:"weak_lens X" and 3:"weak_lens R"
  and     4:"X \<bowtie> Y" and 5:"X \<bowtie> R" and 6:"Y\<bowtie> R"
  shows "\<lceil>(VAR X) =\<^sub>e \<guillemotleft>x\<guillemotright> \<and>\<^sub>e (VAR Y) =\<^sub>e \<guillemotleft>y\<guillemotright>  \<longrightarrow>\<^sub>e
         (R:== (VAR X) ; X :== (VAR Y); Y:== (VAR R))\<dagger>((VAR X) =\<^sub>e\<guillemotleft>y\<guillemotright> \<and>\<^sub>e (VAR Y) =\<^sub>e \<guillemotleft>x\<guillemotright>)\<rceil>"
  using assms unfolding subst_upd_var_def id_def lens_indep_def 
  by transfer auto

subsection {*Hoare triple definition*}
text {*A Hoare triple is represented by a pre-condition @{text P} a post-condition @{text Q}
       and a program @{text C}. It says whenever the pre-condition @{text P} holds then the post-condition
       @{text Q} must hold after the execution of the program @{text C}.*}

abbreviation hoare :: "(bool ,  '\<alpha>) expr \<Rightarrow> '\<alpha> states \<Rightarrow> (bool ,  '\<alpha>) expr \<Rightarrow>  bool" ("\<lbrace>(1_)\<rbrace>/ (_)/\<lbrace>(1_)\<rbrace>") where
"\<lbrace>P\<rbrace>C\<lbrace>Q\<rbrace> \<equiv> \<lceil>P \<longrightarrow>\<^sub>e (C \<dagger> Q)\<rceil>"

lift_definition hoare_valid :: "(bool ,  '\<alpha>) expr \<Rightarrow> '\<alpha> states \<Rightarrow> (bool ,  '\<alpha>) expr \<Rightarrow> bool" ("\<Turnstile> {(1_)}/ (_)/ {(1_)}" 50) is
"\<lambda>P C Q. (\<forall> \<sigma> \<sigma>'. P \<sigma> \<and> C \<sigma> = \<sigma>' \<longrightarrow> Q \<sigma>')" .

lemma Hoare_eq:"\<Turnstile> {P}C{Q} = \<lbrace>P\<rbrace>C\<lbrace>Q\<rbrace>"
  by (transfer, auto)

lemma Hoare_True [hoare_partial]: "\<lbrace>P\<rbrace>C\<lbrace>TRUE\<rbrace>"
  by (transfer, auto)

lemma Hoare_False [hoare_partial]: "\<lbrace>FALSE\<rbrace>C\<lbrace>Q\<rbrace>"
  by (transfer, auto)

subsection {*Hoare for Consequence*}

lemma Hoare_CONSEQ[hoare_partial]:
  assumes 1:"\<lceil>P' \<longrightarrow>\<^sub>e P\<rceil>"  
  and     2:"\<lceil>Q \<longrightarrow>\<^sub>e Q'\<rceil>"
  shows "\<lbrace>P\<rbrace>C\<lbrace>Q\<rbrace> \<longrightarrow> \<lbrace>P'\<rbrace>C\<lbrace>Q'\<rbrace>" 
  using 1 2
  by (transfer, meson) 

subsection {*Precondition strengthening*}

lemma Hoare_Pre_Str[hoare_partial]:
  assumes 1:"\<lceil>P \<longrightarrow>\<^sub>e P'\<rceil>"  
  and     2:"\<lbrace>P'\<rbrace>C\<lbrace>Q\<rbrace>"
  shows "\<lbrace>P\<rbrace>C\<lbrace>Q\<rbrace>" 
  using 1 2 
  by (transfer, auto)

subsection {*Postcondition weakening*}

lemma Hoare_Post_weak[hoare_partial]:
  assumes 1:"\<lbrace>P\<rbrace>C\<lbrace>Q'\<rbrace>"  
  and     2:"\<lceil>Q'\<longrightarrow>\<^sub>e Q\<rceil>"
  shows "\<lbrace>P\<rbrace>C\<lbrace>Q\<rbrace>" 
  using 1 2 
  by (transfer, auto)

subsection {*Hoare and assertion logic*}

lemma Hoare_conjI[hoare_partial]:
  assumes 1:"\<lbrace>P1\<rbrace>C\<lbrace>Q1\<rbrace>"  
  and     2:"\<lbrace>P2\<rbrace>C\<lbrace>Q2\<rbrace>"
  shows "\<lbrace>P1 \<and>\<^sub>e P2\<rbrace>C\<lbrace>Q1 \<and>\<^sub>e Q2\<rbrace>" 
  using 1 2 
  by (transfer, auto)

lemma Hoare_disjI[hoare_partial]:
  assumes 1:"\<lbrace>P1\<rbrace>C\<lbrace>Q1\<rbrace>"  
  and     2:"\<lbrace>P2\<rbrace>C\<lbrace>Q2\<rbrace>"
  shows "\<lbrace>P1 \<or>\<^sub>e P2\<rbrace>C\<lbrace>Q1 \<or>\<^sub>e Q2\<rbrace>" 
  using 1 2 
  by (transfer, auto)
 
subsection {*Hoare for SKIP*}

lemma Hoare_SKIP[hoare_partial]: "\<lbrace>P\<rbrace>SKIP\<lbrace>P\<rbrace>"
   by (transfer, auto)

subsection {*Hoare for assignment*}

lemma Hoare_ASN[hoare_partial]: "\<lbrace>[X \<mapsto>\<^sub>s exp] \<dagger> P\<rbrace>X:== exp\<lbrace>P\<rbrace>" (*I a, not sure if this make sens...*)
  unfolding subst_upd_var_def 
  by (transfer, auto)

lemma Floyd_ASN[hoare_partial]: 
  assumes 1:"weak_lens X" and 2:"weak_lens v" and 3:"X \<bowtie> v" and 4:"v \<sharp> P" and 5:"v \<sharp> exp" 
  shows "\<lbrace>P\<rbrace>X:== exp\<lbrace>\<exists>\<^sub>e v . ((VAR X) =\<^sub>e([X \<mapsto>\<^sub>s (VAR v)]\<dagger> exp)) \<and>\<^sub>e ([X \<mapsto>\<^sub>s (VAR v)]\<dagger> P)\<rbrace>" 
  using assms unfolding subst_upd_var_def  lens_indep_def
  apply simp  apply transfer apply auto oops

lemma Hoare_ASN1[hoare_partial]:
  assumes 1:"weak_lens X" and 2:"X\<sharp> E"
  shows "\<lbrace>TRUE\<rbrace> X:== E \<lbrace>(VAR X) =\<^sub>e E\<rbrace>"
  using 2 1 unfolding subst_upd_var_def unrest_def
  by (transfer, auto)

lemma  Hoare_ASN_bop_test[hoare_partial]:
  assumes 1:"weak_lens Y"  
  shows "\<lbrace>(VAR X) =\<^sub>e \<guillemotleft>1\<guillemotright>\<rbrace>
          Y:== (VAR X)
         \<lbrace>(VAR Y) =\<^sub>e \<guillemotleft>1\<guillemotright>\<rbrace>"
  using 1 unfolding subst_upd_var_def 
  by (transfer, auto) 
 
lemma Hoare_ASN_uop1[hoare_partial]:
  assumes 1:"weak_lens X"  
  shows "\<lbrace>uop P exp\<rbrace>
          X:== exp
         \<lbrace>uop P (VAR X)\<rbrace>" 
  using 1 unfolding subst_upd_var_def    
  by (transfer, auto) 

lemma Hoare_ASN_uop2[hoare_partial]:
  assumes 1:"weak_lens X" and 2:"X \<sharp> exp"
  shows "\<lbrace>uop P exp\<rbrace>
          X:== exp
         \<lbrace>uop P exp\<rbrace>" 
  using 1 2 unfolding subst_upd_var_def unrest_def
  by (transfer, auto) 

lemma Hoare_ASN_uop3[hoare_partial]:
  assumes 1:"weak_lens X"
  shows "\<lbrace>uop P \<guillemotleft>exp\<guillemotright>\<rbrace>
          X:== \<guillemotleft>exp\<guillemotright>
         \<lbrace>uop P \<guillemotleft>exp\<guillemotright>\<rbrace>" 
  using 1 unfolding subst_upd_var_def unrest_def
  by (transfer, auto) 

lemma Hoare_Const_test:
  assumes 1:"weak_lens X" and 2:"X \<bowtie> Y"
  shows "\<lbrace>(VAR Y) =\<^sub>e \<guillemotleft>2\<guillemotright>\<rbrace>X:== \<guillemotleft>2::int\<guillemotright>\<lbrace>(VAR Y) =\<^sub>e(VAR X)\<rbrace>" 
  using 1 2 unfolding subst_upd_var_def lens_indep_def
  by (transfer, auto)

lemma Hoare_ASN_bop1[hoare_partial]:
  assumes 1:"weak_lens X" and 2:"X \<sharp> exp2"
  shows "\<lbrace>bop P exp1 exp2\<rbrace>
          X:== exp1
         \<lbrace>bop P (VAR X) exp2\<rbrace>" 
  using 1 2 unfolding subst_upd_var_def unrest_def 
  by (transfer, auto)

lemma Hoare_ASN_bop2[hoare_partial]:
  assumes 1:"weak_lens X" and 2:"X \<sharp> exp1"
  shows "\<lbrace>bop P exp1 exp2\<rbrace>
          X:== exp2
         \<lbrace>bop P exp1 (VAR X)\<rbrace>" 
  using 1 2 unfolding subst_upd_var_def unrest_def 
  by (transfer, auto)

lemma Hoare_ASN_bop3[hoare_partial]:
  assumes 1:"weak_lens X" 
  shows "\<lbrace>bop P exp1 \<guillemotleft>exp2\<guillemotright>\<rbrace>
          X:== exp1
         \<lbrace>bop P (VAR X) \<guillemotleft>exp2\<guillemotright>\<rbrace>" 
  using 1 unfolding subst_upd_var_def   
  by (transfer, auto)

lemma Hoare_ASN_bop4[hoare_partial]:
  assumes 1:"weak_lens X" 
  shows "\<lbrace>bop P \<guillemotleft>exp1\<guillemotright> exp2\<rbrace>
          X:== exp2
         \<lbrace>bop P \<guillemotleft>exp1\<guillemotright> (VAR X)\<rbrace>" 
  using 1 unfolding subst_upd_var_def   
  by (transfer, auto)

lemma Hoare_ASN_bop5[hoare_partial]:
  assumes 1:"weak_lens X" and 2:"X \<bowtie> Y"
  shows "\<lbrace>bop P (VAR Y) exp2\<rbrace>
          X:== exp2
         \<lbrace>bop P (VAR Y) (VAR X)\<rbrace>" 
  using 1 2 unfolding subst_upd_var_def lens_indep_def 
  by (transfer, auto)

lemma Hoare_ASN_trop1[hoare_partial]:
  assumes 1:"weak_lens X"  and 2:"X \<sharp> exp2" and 3:"X \<sharp> exp3"
  shows "\<lbrace>trop P exp1 exp2 exp3\<rbrace>
          X:== exp1
         \<lbrace>trop P (VAR X) exp2 exp3\<rbrace>" 
  using 1 2 3 unfolding subst_upd_var_def unrest_def 
  by (transfer, auto)

lemma Hoare_ASN_trop2[hoare_partial]:
  assumes 1:"weak_lens X"  and 2:"X \<sharp> exp1" and 3:"X \<sharp> exp3"
  shows "\<lbrace>trop P exp1 exp2 exp3\<rbrace>
          X:== exp2
         \<lbrace>trop P exp1 (VAR X) exp3\<rbrace>" 
  using 1 2 3 unfolding subst_upd_var_def unrest_def 
  by (transfer, auto)

lemma Hoare_ASN_trop3[hoare_partial]:
  assumes 1:"weak_lens X" and 2:"X \<sharp> exp1" and 3:"X \<sharp> exp2"
  shows "\<lbrace>trop P exp1 exp2 exp3\<rbrace> 
          X:== exp3
         \<lbrace>trop P exp1 exp2 (VAR X)\<rbrace>" 
  using 1 2 3 unfolding subst_upd_var_def unrest_def 
  by (transfer, auto)

lemma Hoare_ASN_trop4[hoare_partial]:
  assumes 1:"weak_lens X" 
  shows "\<lbrace>trop P exp1 \<guillemotleft>exp2\<guillemotright> \<guillemotleft>exp3\<guillemotright>\<rbrace>
          X:== exp1
         \<lbrace>trop P (VAR X) \<guillemotleft>exp2\<guillemotright> \<guillemotleft>exp3\<guillemotright>\<rbrace>" 
  using 1 unfolding subst_upd_var_def   
  by (transfer, auto)

lemma Hoare_ASN_trop5[hoare_partial]:
  assumes 1:"weak_lens X" 
  shows "\<lbrace>trop P \<guillemotleft>exp1\<guillemotright> exp2 \<guillemotleft>exp3\<guillemotright>\<rbrace>
          X:== exp2 
         \<lbrace>trop P \<guillemotleft>exp1\<guillemotright> (VAR X) \<guillemotleft>exp3\<guillemotright>\<rbrace>" 
  using 1 unfolding subst_upd_var_def   
  by (transfer, auto)

lemma Hoare_ASN_trop6[hoare_partial]:
  assumes 1:"weak_lens X" 
  shows "\<lbrace>trop P \<guillemotleft>exp1\<guillemotright> \<guillemotleft>exp2\<guillemotright> exp3\<rbrace>
          X:== exp3
         \<lbrace>trop P \<guillemotleft>exp1\<guillemotright> \<guillemotleft>exp2\<guillemotright> (VAR X)\<rbrace>" 
  using 1 unfolding subst_upd_var_def   
  by (transfer, auto)

lemma Hoare_ASN_qtop1[hoare_partial]:
  assumes 1:"weak_lens X"  and 2:"X \<sharp> exp2" and 3:"X \<sharp> exp3"  and 4:"X \<sharp> exp4"
  shows "\<lbrace>qtop P exp1 exp2 exp3 exp4\<rbrace>
          X:== exp1
         \<lbrace>qtop P (VAR X) exp2 exp3 exp4\<rbrace>" 
  using 1 2 3 4 unfolding subst_upd_var_def unrest_def 
  by (transfer, auto)

lemma Hoare_ASN_qtop2[hoare_partial]:
  assumes 1:"weak_lens X" and 2:"X \<sharp> exp1" and 3:"X \<sharp> exp3" and 4:"X \<sharp> exp4"
  shows "\<lbrace>qtop P exp1 exp2 exp3 exp4\<rbrace>
          X:== exp2
         \<lbrace>qtop P exp1 (VAR X) exp3 exp4\<rbrace>" 
  using 1 2 3 4 unfolding subst_upd_var_def unrest_def 
  by (transfer, auto)

lemma Hoare_ASN_qtop3[hoare_partial]:
  assumes 1:"weak_lens X" and 2:"X \<sharp> exp1" and 3:"X \<sharp> exp2" and 4:"X \<sharp> exp4"
  shows "\<lbrace>qtop P exp1 exp2 exp3 exp4\<rbrace>
          X:== exp3
         \<lbrace>qtop P exp1 exp2 (VAR X) exp4\<rbrace>" 
  using 1 2 3 4 unfolding subst_upd_var_def unrest_def 
  by (transfer, auto)

lemma Hoare_ASN_qtop4[hoare_partial]:
  assumes 1:"weak_lens X" and 2:"X \<sharp> exp1" and 3:"X \<sharp> exp2" and 4:"X \<sharp> exp3"
  shows "\<lbrace>qtop P exp1 exp2 exp3 exp4\<rbrace>
          X:== exp4
         \<lbrace>qtop P exp1 exp2 exp3 (VAR X)\<rbrace>" 
  using 1 2 3 4 unfolding subst_upd_var_def unrest_def 
  by (transfer, auto)

lemma Hoare_ASN_qtop5[hoare_partial]:
  assumes 1:"weak_lens X" 
  shows "\<lbrace>qtop P exp1 \<guillemotleft>exp2\<guillemotright> \<guillemotleft>exp3\<guillemotright> \<guillemotleft>exp4\<guillemotright>\<rbrace>
          X:== exp1
         \<lbrace>qtop P (VAR X) \<guillemotleft>exp2\<guillemotright> \<guillemotleft>exp3\<guillemotright> \<guillemotleft>exp4\<guillemotright>\<rbrace> " 
  using 1 unfolding subst_upd_var_def   
  by (transfer, auto)

lemma Hoare_ASN_qtop6[hoare_partial]:
  assumes 1:"weak_lens X" 
  shows "\<lbrace>qtop P \<guillemotleft>exp1\<guillemotright> exp2 \<guillemotleft>exp3\<guillemotright> \<guillemotleft>exp4\<guillemotright>\<rbrace>
          X:== exp2
         \<lbrace>qtop P \<guillemotleft>exp1\<guillemotright> (VAR X) \<guillemotleft>exp3\<guillemotright> \<guillemotleft>exp4\<guillemotright>\<rbrace>" 
  using 1 unfolding subst_upd_var_def   
  by (transfer, auto)

lemma Hoare_ASN_qtop7[hoare_partial]:
  assumes 1:"weak_lens X" 
  shows "\<lbrace>qtop P \<guillemotleft>exp1\<guillemotright> \<guillemotleft>exp2\<guillemotright> exp3 \<guillemotleft>exp4\<guillemotright>\<rbrace>
          X:== exp3
         \<lbrace>qtop P \<guillemotleft>exp1\<guillemotright> \<guillemotleft>exp2\<guillemotright> (VAR X) \<guillemotleft>exp4\<guillemotright>\<rbrace>" 
  using 1 unfolding subst_upd_var_def  
  by (transfer, auto)

subsection {*Hoare for Sequential Composition*}

lemma Hoare_SEQ[hoare_partial]:
  assumes 1:"\<lbrace>P\<rbrace>C1\<lbrace>Q\<rbrace>"  
  and     2:"\<lbrace>Q\<rbrace>C2\<lbrace>R\<rbrace>"
  shows "\<lbrace>P\<rbrace>C1;C2\<lbrace>R\<rbrace>" 
  using 1 2 
  by (transfer, (metis comp_apply))

subsection {*Hoare for Conditional*}

lemma Hoare_COND[hoare_partial]:
  assumes 1:"\<lbrace>P \<and>\<^sub>e b\<rbrace>C1\<lbrace>Q\<rbrace>"  
  and     2:"\<lbrace> P \<and>\<^sub>e (\<not>\<^sub>e b)\<rbrace>C2\<lbrace>Q\<rbrace>"
  shows "\<lbrace>P\<rbrace>IF b THEN C1 ELSE C2\<lbrace>Q\<rbrace>" 
  using 1 2 
  by (transfer, metis (full_types, hide_lams))   

subsection {*Hoare for While-loop*}

lemma Hoare_WHILE[hoare_partial]:
  assumes 1:"\<lbrace>P \<and>\<^sub>e b\<rbrace>C\<lbrace>P\<rbrace>"  
  shows "\<lbrace>P\<rbrace>WHILE b DO C OD\<lbrace>P \<and>\<^sub>e (\<not>\<^sub>eb)\<rbrace>" 
  using 1
  apply transfer
oops  

subsection {*Hoare for Assert*}
lemma Hoare_ASSERT[hoare_partial]:
  assumes 1:"\<lbrace>P \<and>\<^sub>e b\<rbrace>C\<lbrace>Q\<rbrace>"
  and     2:"\<lbrace> P \<and>\<^sub>e (\<not>\<^sub>e b)\<rbrace>SKIP\<lbrace>Q\<rbrace>"
  shows "\<lbrace>P\<rbrace>assert {b} C\<lbrace>Q\<rbrace>" 
  using 1 2
  by transfer simp

lemma 
  assumes 1:"weak_lens X"
  shows"\<lbrace>(VAR X) =\<^sub>e \<guillemotleft>0::int\<guillemotright>\<rbrace>X :== ((VAR X) +\<^sub>e \<guillemotleft>1\<guillemotright>) \<lbrace>(VAR X) =\<^sub>e \<guillemotleft>1\<guillemotright>\<rbrace>" 
  using 1 unfolding subst_upd_var_def apply transfer apply auto done

lemma
  assumes 1:"weak_lens X"  
  shows "\<lbrace>uop P \<guillemotleft>exp\<guillemotright> \<and>\<^sub>e (P \<longrightarrow>\<^sub>e Q)\<rbrace>
          X:== (uop Q \<guillemotleft>exp\<guillemotright>)
         \<lbrace>uop P (VAR X)\<rbrace>" 
  using 1 unfolding subst_upd_var_def    
  apply transfer apply auto
  oops

end