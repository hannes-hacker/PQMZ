(*1: ctrl c & ctrl n (evaluate one line)
2: ctrl c & ctrl u (step back a line)
3: ctrl x & ctrl s (save)
4: ctrl x & ctrl c (quit)*)

require import Real Bool DBool FSet Int IntDiv SmtMap FMap.
require import AllCore List Distr DProd DInterval Mu_mem.
require ROM ZModP.

import StdOrder.RealOrder StdBigop.Bigreal.BRA.
  pragma -oldip. pragma +implicits.

(* ------------------------------------------------------- *)
theory PolyRing.

(* Falcon standard public key material:
   h in Z_q[x]/(x^n+1). *)
type poly.

op zerop : poly. (* additive identity 0    *)
op onep  : poly. (* multiplicative identity 1 *)

(* RING Operations *)
  (* All ring expressions in the file use:                               *)
(*   mulp a b   for a * b  in Zq[x]/phi                               *)
(*   addp a b   for a + b  in Zq[x]/phi                               *)
(*   subp a b   for a - b  in Zq[x]/phi                               *)
(*   inv_p a    for a^{-1} in Zq[x]/phi (when invertible)             *)
  (* ------------------------------------------------------------------ *)
op addp : poly -> poly -> poly.  (* ring addition    mod (phi,q)  *)
op mulp : poly -> poly -> poly. (* ring multiplication mod (phi,q) *)

op opp  : poly -> poly. (*op ret the additive inv (negative) of poly.  opp(a) = −a *)
op subp : poly -> poly -> poly. (* ring subtraction mod (phi,q)    *)

(* total inverse *)
op inv_p : poly -> poly.

(* invertible s2: s2 has a multiplicative inverse in Zq[x]/(phi).
  Equivalently: none of s2's NTT coefficients are zero.
  Algorithm 1 Section 3.3 checks this and rejects until satisfied.*)
(* invertibility predicate *)
op invertible (x : poly) : bool. 
(*op invertible : poly -> bool.*)

(* Subtraction is defined via the additive inverse:
      x - y := x + (-y)
   where opp(y) represents the additive inverse (-y). *)
axiom sub_def (x y : poly) :
  subp x y = addp x (opp y).

(*----------------------------------- *)
(* Additive Abelian Group  *)

axiom add_assoc (a b c : poly) :
  addp (addp a b) c = addp a (addp b c).


axiom add_comm (a b : poly) :
  addp a b = addp b a.

(*left identity,  0+a =a   *)
axiom add_zero_l (a : poly) :
  addp zerop a = a.

(* right identity *)
axiom add_zero_r (a : poly) :
  addp a zerop = a.

(* left inv    -a + a =0  *)
axiom add_opp_l (a : poly) :
  addp (opp a) a = zerop.

(* right inv *)
axiom add_opp_r (a : poly) :
  addp a (opp a) = zerop.
 
(* *------------------------------------- *)
(* Multiplication  *)

(*Associativity  (ab)c = a(bc) *)
axiom mul_assoc (a b c : poly) :
  mulp (mulp a b) c = mulp a (mulp b c).

(*Commutativity:  ab =ba  *)
axiom mul_comm (a b : poly) :
  mulp a b = mulp b a.

(* Left identity:  1a=a  *)
axiom mul_one_l (a : poly) :
  mulp onep a = a.

(* right identity  *)
axiom mul_one_r (a : poly) :
  mulp a onep = a.

(* Multiplication by zero:   0a = 0  *) 
axiom mul_zero_l (a : poly) :
  mulp zerop a = zerop.

(* a0 = 0  *)   
axiom mul_zero_r (a : poly) :
    mulp a zerop = zerop.

(* ------------------------------------- *)
(* Distributivity  *)

(* a(b+c) = ab + ac  *)
axiom distrib_l (a b c : poly) :
  mulp a (addp b c) = addp (mulp a b) (mulp a c).

(* (a +b)c = ac + bc *)  
axiom distrib_r (a b c : poly) :
    mulp (addp a b) c = addp (mulp a c) (mulp b c).

(*  ------------------------------------- *)
(* Multiplicative inverse  *)
(* a^-1 a = 1 *)
  axiom inv_spec a :
  invertible a => mulp (inv_p a) a = onep.

(* a a^-1  = 1 *)
  axiom inv_spec_r a :
    invertible a => mulp a (inv_p a) = onep.

(*  ------------------------------------------------------ *)
    (* Derived additive lemmas   *)
  
lemma add_cancel_l (a b : poly) :
    addp (opp a) (addp a b) = b.
proof.
    rewrite -add_assoc add_opp_l add_zero_l //=.
qed.

  (* add_cancel_r: (a + b) + (-a) = b. *)
lemma add_cancel_r (a b : poly) :
    addp (addp a b) (opp a) = b.
proof.
  (* (a+b)+(-a) = (b+a)+(-a) = b+(a+(-a)) = b+0 = b *)
   smt(add_assoc add_comm add_zero_l add_zero_r add_opp_l add_opp_r). 
qed.

  (* add_left_cancel: a+b = a+c => b = c. *)
lemma add_left_cancel (a b c : poly) :
    addp a b = addp a c => b = c.
proof.
    move=> H.
    have H1 : addp (opp a) (addp a b) = addp (opp a) (addp a c) by rewrite H.
    rewrite !add_cancel_l in H1.
    exact H1.
qed.

(* opp_zero: -(0) = 0.*)
lemma opp_zero :
  opp zerop = zerop.
proof.
  apply (add_left_cancel zerop).
  rewrite add_opp_r add_zero_l //=.
qed.

(* opp_opp: -(-a) = a. *)
lemma opp_opp (a : poly) : opp (opp a) = a.
proof.
   apply (add_left_cancel (opp a)).
   rewrite add_opp_r add_opp_l //=.
qed.

(* Subtraction lemmas *)
lemma sub_zero_r (a : poly) : subp a zerop = a.
proof. rewrite sub_def opp_zero add_zero_r //=. qed.

lemma zero_sub (a : poly) : subp zerop a = opp a.
proof. rewrite sub_def add_zero_l //=. qed.

lemma sub_self (a : poly) : subp a a = zerop.
proof. rewrite sub_def add_opp_r //=. qed.

(* sub_add: (a - b) + b = a.*)
lemma sub_add (a b : poly) : addp (subp a b) b = a.
proof.
   rewrite sub_def add_assoc add_opp_l add_zero_r //=.
qed.

  (*add_sub: (a + b) - b = a. *)
lemma add_sub (a b : poly) : subp (addp a b) b = a.
proof.
    rewrite sub_def add_assoc add_opp_r add_zero_r //=.
qed.

 (* ------------------------------------------------ *)
  (* KEY CANCELLATION LEMMAS FOR PKR  *)
  (* subp_cancel: (a + b) - a = b.
    This is the CENTRAL lemma used in pkr_fwd:
    when c = addp s1 (mulp s2 h), we have subp c s1 = mulp s2 h. *)

lemma subp_cancel (a b : poly) : subp (addp a b) a = b.
proof.
   smt(sub_def add_assoc add_comm add_opp_r add_zero_r). 
qed.

(* subp_to_addp: (c - a = b) => (a + b = c).
    This is used in pkr_conv: from subp c s1 = mulp s2 h,
    derive addp s1 (mulp s2 h) = c. *)

lemma subp_to_addp (a b c : poly) :
    subp c a = b => addp a b = c.
proof.
      smt(sub_def add_assoc add_comm
      add_opp_l add_opp_r
      add_zero_l add_zero_r).
qed.

    (* MULTIPLICATIVE INVERSE LEMMAS *)
(* if a^−1 exists then  a^−1 (ab) =b *)
lemma mul_inv_cancel (a b : poly) :
    invertible a => mulp (inv_p a) (mulp a b) = b.
  proof.
    smt(mul_assoc mul_one_l inv_spec).
  qed.

  (*a(a^−1 b) =b. *)
lemma mul_inv_cancel_r (a b : poly) :
    invertible a => mulp a (mulp (inv_p a) b) = b.
  proof.
    smt(mul_assoc mul_one_l inv_spec_r).
qed.

end PolyRing.
  (* -----------ends here---------------------------------- *)
import PolyRing.

  (* PKR ALGEBRAIC LEMMAS:
  PKR equation s1​+s2​h=c.  *)
  (* pkr_fwd: if s2 invertible AND s1 + s2*h = c,
             THEN inv(s2) * (c - s1) = h.
    Proof:
      Step 1: c - s1 = subp (addp s1 (mulp s2 h)) s1
                     = mulp s2 h          [by subp_cancel]
  Step 2: inv(s2) * (s2 * h) = h     [by mul_inv_cancel] *)

(** standard Falcon equation --> public-key recovery equation **)
lemma pkr_fwd (s1 s2 h c : poly) :
    invertible s2 =>
    addp s1 (mulp s2 h) = c =>
    mulp (inv_p s2) (subp c s1) = h.
proof.
    move=> Hinv Heq.
    have Hcs1 : subp c s1 = mulp s2 h.
    + rewrite -Heq. exact (subp_cancel).
    rewrite Hcs1.
    exact (mul_inv_cancel).
qed.

 (**proves the converse: Recovered public key --> standard Falcon eq  **)

  (* pkr_conv: if s2 invertible AND inv(s2) * (c - s1) = h,
              THEN s1 + s2*h = c. *)
lemma pkr_conv (s1 s2 h c : poly) :
  invertible s2 =>
  mulp (inv_p s2) (subp c s1) = h =>
  addp s1 (mulp s2 h) = c.
proof.
    move=> Hinv Hrec.
    have Hcs1 : subp c s1 = mulp s2 h.
    + have Hm : mulp s2 (mulp (inv_p s2) (subp c s1)) = mulp s2 h
        by rewrite Hrec.
      rewrite (mul_inv_cancel_r  Hinv) in Hm.
      exact Hm.
    exact (subp_to_addp  Hcs1).
qed.

(* Eq. 3 recovery is equivalent to Eq. 1 standard signing,
     invertible s2 => (s1+s2h=c <=> s2^-1(c-s1)=h). *)
lemma recovery_soundness (s1 s2 h c : poly) :
  invertible s2 =>
  (addp s1 (mulp s2 h) = c
   <=>
   mulp (inv_p s2) (subp c s1) = h).
proof.
  move=> Hinv.
  split.
  - exact (pkr_fwd  Hinv).
  - exact (pkr_conv Hinv).
qed.

 (* ---------------------------------------------------------------- *)
type message.
  (*type pkey.  *)     (* =  h in Zq[x]/(x^n+1)  with h = g*f^{-1} mod (phi,q) *)

type skey.          (* = (f,g,F,G) with fG-gF=q mod phi, f invertible   *)
type salt.          (* = r sampled uniformly from  {0,1}^320 *)
type pkHash.

op Hpk : poly -> pkHash.

  (* Signature types -- abstracting away Compress/Decompress *)
(* sig_std = (r, s2): standard Falcon sig. s1 dropped, recomputed    *)
(* by verifier as s1 = c - s2*h.     *)
type sig_std = salt * poly.           (* (r, s2) *)

(* sig_pkr = (r, s1, s2): PKR signature. s1 included so verifier   *)
(* can recover h = inv(s2)*(c-s1).     *)
type sig_pkr = salt * poly * poly.    (* (r, s1, s2) *)

  (*-------------------------------
  NORM AND BOUND 
  norm_sq2 s1 s2 = ||(s1,s2)||^2 = sum of squared coefficients.
  From Section 3.1: beta = tau_SIG * sigma * sqrt(2n), tau_SIG=1.1.
  Signature accepted iff norm_sq2 s1 s2 <= floor(beta^2).
  -------------------------------*)
op norm_sq2   : poly -> poly -> real.
const beta_sq : real.   (* floor(beta^2) *)

(*-------------------------------
  norm_decomp and norm_nonneg are needed for norm_s2_le and pkr_to_std_eq.
  **Norm decomposition.
  
  ||(s1,s2)||^2 = ||s1||^2 + ||s2||^2.
  Needed for extraction: PKR forgery norm ok implies s2 norm ok.
-------------------------------  *)
axiom norm_decomp (s1 s2 : poly) :
  norm_sq2 s1 s2 = norm_sq2 zerop s1 + norm_sq2 zerop s2.

axiom norm_nonneg (s : poly) :
  0%r <= norm_sq2 zerop s.


(* ----- DERIVED LEMMAS-now!!-----  *)
(* Derived: ||(s1,s2)||^2 <= beta^2 implies ||(0,s2)||^2 <= beta^2. *)
lemma norm_s2_le (s1 s2 : poly) :
  norm_sq2 s1 s2 <= beta_sq =>
  norm_sq2 zerop s2 <= beta_sq.
proof. smt(norm_decomp norm_nonneg). qed. 

(*-------------------------------
  Core algebraic lemma: PKR verify accept => standard Falcon eq holds.
  Direct consequence of A2 + norm bound.
  pkr_to_std_eq: PKR verify accept => standard Falcon equation holds.
-------------------------------*)
lemma pkr_to_std_eq (s1 s2 pk c : poly) :
  invertible s2 =>
  mulp (inv_p s2) (subp c s1) = pk =>
  norm_sq2 s1 s2 <= beta_sq =>
  addp s1 (mulp s2 pk) = c /\ norm_sq2 s1 s2 <= beta_sq.
proof. 
  (*move=> hinv hrec hnorm.  smt. *)
    move=> hinv hrec hnorm.
  split.
  - exact (pkr_conv   hinv hrec).
  - exact hnorm.
qed.

(* ------------------------------------------------------------------ *)
(* RANDOM ORACLE FOR HashToPoint   c=H-TP​(r,m).  *)

op dpoly : poly distr.
axiom dpoly_ll : is_lossless dpoly.

module RO = {
  var mp : (salt * message, poly) fmap

  proc init() : unit = {
    mp <- empty;
  }

  proc hash(r : salt, m : message) : poly = {
      var c, x;

    c <- mp.[(r,m)]; 

    if (c = None) {
      
      x <$ dpoly;
      mp.[(r,m)] <- x;
      c <- Some x;
    }

   return oget c;
  }
}.

lemma RO_init_ll : islossless RO.init.
proof. proc. auto. qed.

lemma RO_hash_ll : islossless RO.hash.
proof.
    proc. 
    sp. if => //. auto=> />. smt(dpoly_ll).
qed.

(*Helper equiv lemma for RO.hash.
  Both sides call RO.hash with equal state and args.*)
lemma RO_hash_equiv :
  equiv[RO.hash ~ RO.hash :
    ={RO.mp, arg} ==> ={res, RO.mp}].
proof. proc.  sp. if => //. auto=> />.  qed.
 
(* ------------------------------------------------------------------ *)
(*SIGNATURE SCHEME MODULE TYPE   *)

(*  Standard Falcon verify(pk, m, (r,s2)):  
   c  := HashToPoint(r||m)   
   s1 := c - s2*pk       (recompute from spec)  
   accept iff norm_sq2 s1 s2 <= beta_sq*)

module type Sig_T = {
  proc keygen  ()       : poly * skey
  proc sign    (sk : skey, m : message)    : sig_std
  proc verify  (pk : poly, m : message, s : sig_std) : bool
}.


(* -------------------------------------------------- *)
 (* ORACLE and ADVERSARY module TYPES   *)

module type Oracle_Std_T = {
  proc sign(m : message) : sig_std
}.

module type Oracle_PKR_T = {
  proc sign(m : message) : sig_pkr
}.

(*Adversary against standard EUF-CMA.
  Gets signing oracle O and access to global RO module. *)

(* Adversary takes poly pk (not pkey) *)
module type Adv_Std (O : Oracle_Std_T) = {
  proc forge(pk : poly) : message * sig_std
}.

module type Adv_PKR (O : Oracle_PKR_T) = {
  proc forge(pk : pkHash) : message * sig_pkr
}.


(* ------------------------------------------------------------------ *)

module PKR_Verify (*(H : PKHash)*) = {
  proc verify(pk : pkHash, m : message, s : sig_pkr) : bool = {
    var r, s1, s2, c, h_rec, pk_rec;

    (r, s1, s2) <- s;

    c     <@ RO.hash(r, m);

    h_rec <- mulp (inv_p s2) (subp c s1);

      (*pk_rec <@ H.hash(h_rec);*)
    pk_rec <- Hpk h_rec;

    return (invertible s2) /\
           (pk_rec = pk) /\
           (norm_sq2 s1 s2 <= beta_sq);
  }
}.

lemma PKR_Verify_ll (*(H <: PKHash)*) :
  islossless PKR_Verify.verify.
proof.
  proc.
  wp.
  call RO_hash_ll.
  auto.
qed.


(* ------------------------------------------------------------- *)
(*STANDARD EUF-CMA GAME   *)

module EUF_CMA_Std (S : Sig_T) (A : Adv_Std) = {
  var sk : skey
  var qs : message list

  module O : Oracle_Std_T = {
    proc sign(m : message) : sig_std = {
      var s;
      s  <@ S.sign(sk, m);
      qs <- m :: qs;
      return s;
    }
  }

  proc main() : bool = {
    var pk, m, s, b;
    RO.init();
    (pk, sk) <@ S.keygen();
    qs <- [];
    (m, s)  <@ A(O).forge(pk);
    b       <@ S.verify(pk, m, s);
    return b /\ !(m \in qs);
  }
}.

(* ------------------------------------------------------------------ *)
(* PKR EUF-CMA GAME 
    The actual Falcon public key is h : poly.
    Falcon-PKR stores/exposes only pk_h = H(h).
    
   The signing oracle still uses the underlying polynomial h to
    construct s1 = c - s2*h,
    while the adversary receives pk_h.The externally visible public key is pk_h = H(h).  *)

module EUF_CMA_PKR
  (S : Sig_T)
  (A : Adv_PKR)
  (*(H : PKHash) *) = {

  var sk  : skey
  var h   : poly
  var pk_h : pkHash
  var qs  : message list

    
  module O : Oracle_PKR_T = {

    proc sign(m : message) : sig_pkr = {
      var r, s2, c0, s1;

      (* Standard Falcon signing *)
      (r, s2) <@ S.sign(sk, m);

      (* HashToPoint. (Fiat-Shamir challenge) *)
      c0 <@ RO.hash(r, m);

      (* Recoverable-signature component.
         s1 = c - s2*h. *)
      s1 <- subp c0 (mulp s2 h);

      qs <- m :: qs;

      return (r, s1, s2);
    }
  }

   proc main() : bool = {
    var m : message;
      var sig : sig_pkr;
      var r, s1, s2;
    var c : poly;
    var b : bool;

    RO.init();
    
    (* Standard Falcon key generation gives h. *)
    (h, sk) <@ S.keygen();

     pk_h <- Hpk h;
       qs <- [];

    (* The adversary sees H(h), not h. *)
    (m, sig) <@ A(O).forge(pk_h);

     (r, s1, s2) <- sig;

    c <@ RO.hash(r, m);

    b <@ PKR_Verify.verify(pk_h, m, sig);

    return b /\ !(m \in qs);
  }
}.

(* ------------------------------------------------------------------ *)
    (* PKR GAME WITH EXPLICIT COLLISION EVENT !!!
    
   G_PKR_CR is identical to EUF_CMA_PKR except that it explicitly
   records the event

       badCR =
           (h_rec <> h)
           /\
           (Hpk(h_rec) = Hpk(h)).

   This event captures exactly the additional failure introduced
   by storing Hpk(h) instead of h itself.*)

module G_PKR_CR
  (S : Sig_T)
  (A : Adv_PKR) = {

  var h : poly
  var sk : skey
  var pk_h : pkHash
  var qs : message list
    
  (* These are globals deliberately: they form the invariant used by the verification game hop. *)
  var c : poly
  var h_rec : poly
  var pk_rec : pkHash
  var badCR : bool

  module O : Oracle_PKR_T = {

    proc sign(m : message) : sig_pkr = {
      var r, s2, c0, s1;

      (* Standard Falcon signing. *)
      (r, s2) <@ S.sign(sk, m);

      (* Fiat-Shamir challenge. *)
      c0 <@ RO.hash(r, m);

      (* PKR signature component. *)
      s1 <- subp c0 (mulp s2 h);

      qs <- m :: qs;

      return (r, s1, s2);
    }
  }

  proc main() : bool = {
    var m : message;
    var sig : sig_pkr;
    var r, s1, s2;
    var b : bool;

    RO.init();

    (* Generate real Falcon key pair. *)
    (h, sk) <@ S.keygen();
    (* Publicly stored PKR public key. *)
    pk_h <- Hpk h;
      qs <- [];

    (* Initialise instrumentation *)
    badCR <- false;

    (* Run PKR adversary. *)
    (m, sig) <@ A(O).forge(pk_h);

    (* Extract signature components. *)
    (r, s1, s2) <- sig;

    (* Recompute Fiat-Shamir challenge. *)
    c <@ RO.hash(r, m);

    (* Recover candidate public key. *)
    h_rec <- mulp (inv_p s2) (subp c s1);

    (* Hash recovered public key. *)
    pk_rec <- Hpk h_rec;

    (* Explicit collision event. *)
    badCR <- (h_rec <> h) /\ (pk_rec = pk_h);

    (* Actual PKR verification. *)
    b <@ PKR_Verify.verify(pk_h, m, sig);

    return b /\ !(m \in qs);
  }
}.

    (* ------------------------------------------------------------------ *)
(* STANDARD FALCON REFERENCE VERIFIER  *)
module RefVerify = {
    
  proc verify(pk : poly, m : message, s : sig_std) : bool = {
  var r, s2, c;
    
    (r, s2) <- s;
      c <@ RO.hash(r, m);
    
    return norm_sq2
     (subp c (mulp s2 pk)) s2 <= beta_sq;
  }
}.


module G_mid_ref
  (S : Sig_T)
  (A : Adv_PKR) = {

  var h    : poly
  var sk   : skey
  var pk_h : pkHash
  var qs   : message list

  module O = {

    proc sign(m : message) : sig_pkr = {

    var r,s2,c0,s1;
      
 (* Same signing experiment as EUF_CMA_PKR. *)
      (r,s2) <@ S.sign(sk,m);

      c0 <@ RO.hash(r,m);

      s1 <- subp c0 (mulp s2 h);

      qs <- m :: qs;

      return (r,s1,s2);
    }
  }

  proc main() : bool = {

      var m : message;
      var sig : sig_pkr;
      var r,s1,s2;
      var b : bool;

      RO.init();

      (h,sk) <@ S.keygen();

      pk_h <- Hpk h;

      qs <- [];

      (m,sig) <@ A(O).forge(pk_h);

      (r,s1,s2) <- sig;

      b <@ RefVerify.verify(h,m,(r,s2));

      return b /\ !(m \in qs);
  }
}.


(* ------------------------------------------------------------- *)
(* COLLISION-RESISTANCE GAME FOR THE PUBLIC-KEY HASH
   A collision consists of two distinct Falcon public-key polynomials h1 & h2 such that

       Hpk(h1) = Hpk(h2).

   Hpk is deterministic, so it is represented as an operator
    rather than an oracle/module.   *)

module type CR_Adv (*(H : PKHash)*) = {
  proc find() : poly * poly }.

module CR_PKHash (B : CR_Adv) (* (H : PKHash)*) = {
  proc main() : bool = {
    var h1, h2 : poly;
    var pk1, pk2 : pkHash;

    (h1, h2) <@ B.find();

    return (h1 <> h2) /\ (Hpk h1 = Hpk h2);
  }
}.

(* ------------------------------------------------------------------ *)
 (* REDUCTION TO COLLISION RESISTANCE OF Hpk !!!
    
   Given a PKR adversary A, Red_CR runs A using the hashed
   public key Hpk(h).

   If A produces a PKR forgery whose recovered polynomial h_rec
   differs from the real Falcon public key h but nevertheless
   satisfies

       Hpk(h_rec) = Hpk(h),

   then (h,h_rec) is a collision for Hpk.

   The reduction therefore extracts exactly the pair needed by
   the collision-resistance game. *)

module Red_CR
  (S : Sig_T)
  (A : Adv_PKR) = {

  var h : poly
  var sk : skey

  module O : Oracle_PKR_T = {

    proc sign(m : message) : sig_pkr = {
      var r, s2, c, s1;

      (* Obtain the ordinary Falcon signature. *)
      (r, s2) <@ S.sign(sk, m);

      (* Fiat-Shamir challenge. *)
      c <@ RO.hash(r, m);

      (* PKR signing transformation:
           s1 = c - s2*h
       so that
           s1 + s2*h = c. *)
      s1 <- subp c (mulp s2 h);

      return (r, s1, s2);
    }
  }

  proc find() : poly * poly = {
    var pk_h : pkHash;
    var m : message;
    var sig : sig_pkr;
    var r, s1, s2;
    var c : poly;
    var h_rec : poly;

    (* Fresh random oracle for this game. *)
    RO.init();

    (* Generate the real Falcon key pair. *)
    (h, sk) <@ S.keygen();

    (* The adversary receives the hashed public key. *)
    pk_h <- Hpk h;

    (* Run the PKR adversary with the simulated signing oracle. *)
    (m, sig) <@ A(O).forge(pk_h);

    (* Extract the PKR signature components. *)
    (r, s1, s2) <- sig;

    (* Recompute the Fiat-Shamir challenge. *)
    c <@ RO.hash(r, m);

    (* Recover the public-key candidate from the forgery:
           h_rec = s2^{-1} * (c - s1). *)
    h_rec <- mulp (inv_p s2) (subp c s1);

    (* Output the real and recovered public-key polynomials. *)
    return (h, h_rec);
  }
}.


(* -------------------------------------------------------- *)
(* SIMULATED PKR SIGNING ORACLE
   The standard Falcon challenger gives the reduction the actual public-key polynomial h.

   SimOracle converts each ordinary Falcon signature

       (r,s2)

   into the PKR signature

       (r,s1,s2)

   where

       s1 = c - s2*h_sim.

   The reduction therefore provides the PKR adversary with a
   perfect simulation of the PKR signing oracle. *)

module SimOracle
  (S : Sig_T)
  (O : Oracle_Std_T) = {

  var h_sim : poly

  proc sign(m : message) : sig_pkr = {
    var r, s2, c, s1;

    (* Ask the standard signing oracle for (r,s2). *)
    (r, s2) <@ O.sign(m);

    (* Recompute Fiat-Shamir challenge. *)
    c <@ RO.hash(r, m);

    (* Convert to PKR signature. *)
    s1 <- subp c (mulp s2 h_sim);

    return (r, s1, s2);
  }
}.


(* -------------------------------------------------- *)
(* REDUCTION FROM PKR TO STANDARD FALCON
 The standard Falcon challenger gives Red2 the actual public
   key polynomial h.

   Red2 computes Hpk(h), gives this hashed key to A, and
   simulates PKR signing queries using h.

   From A's PKR forgery (r,s1,s2), Red2 returns the ordinary
   Falcon signature (r,s2).   *)

module Red2
  (S : Sig_T)
  (A : Adv_PKR)
  (O : Oracle_Std_T) = {

  module SO = SimOracle(S, O)

  proc forge(pk : poly) : message * sig_std = {

    var pk_h : pkHash;
    var m : message;
    var sig : sig_pkr;
    var r, s1, s2;

    SO.h_sim <- pk;

    pk_h <- Hpk pk;

    (m, sig) <@ A(SO).forge(pk_h);

    (r, s1, s2) <- sig;

    return (m, (r, s2));
  }
}.

(*----------------------------------------------------- *)
(*  SECURITY PROOF    *)

section Security.

declare module S <: Sig_T
{-RO, -EUF_CMA_PKR, -EUF_CMA_Std, -G_mid_ref ,
  -G_PKR_CR, -Red2, -Red_CR, -SimOracle}.

declare module A <: Adv_PKR
{-S, -RO, -EUF_CMA_PKR, -EUF_CMA_Std, -G_mid_ref ,
  -G_PKR_CR,  -Red2, -Red_CR, -SimOracle}.


axiom S_keygen_ll : islossless S.keygen.
axiom S_sign_ll   : islossless S.sign.
axiom S_verify_ll : islossless S.verify.

(* PPT-adversary termination(pen-and-paper), needed for the reduction to type-check. *)    
axiom A_forge_ll (O <: Oracle_PKR_T {-Red2, -Red_CR}) :
     islossless A(O).forge.

lemma RefVerify_verify_ll : islossless RefVerify.verify.
    proof. proc. wp. call RO_hash_ll. auto. qed.

(* ABSTRACT STANDARD VERIFIER AGREES WITH REFERENCE VERIFIER!! *) 
axiom S_verify_matches_ref :
  equiv[ S.verify ~ RefVerify.verify :
  ={arg} /\ ={RO.mp} ==> ={res} /\ ={RO.mp} ].

(*------------------------------------------------- *)
(* SELF-EQUIVALENCE OF S  *)
axiom S_keygen_equiv :
    equiv[S.keygen ~ S.keygen :
      ={glob S} ==> ={res, glob S}].

axiom S_sign_equiv :
    equiv[S.sign ~ S.sign :
      ={glob S, arg} ==> ={res, glob S}].

axiom S_verify_equiv :
    equiv[S.verify ~ S.verify :
        ={glob S, arg} ==> ={res, glob S}].
 
  (*NOW we have: EUF_CMA_PKR --> G_PKR_CR *)
local lemma step1a &m :
    Pr[EUF_CMA_PKR(S,A).main() @ &m : res]
    =
    Pr[G_PKR_CR(S,A).main() @ &m : res].
proof.
  byequiv (_ :
      ={glob S, glob A, RO.mp}
      ==> ={res}).
  proc.
  inline RO.init.
  (* Key generation and public-key construction. *)
  seq 4 5 : ( ={glob S, glob A, RO.mp}
      /\ EUF_CMA_PKR.h{1} = G_PKR_CR.h{2}
      /\ EUF_CMA_PKR.sk{1} = G_PKR_CR.sk{2}
      /\ EUF_CMA_PKR.pk_h{1} = G_PKR_CR.pk_h{2}
      /\ EUF_CMA_PKR.qs{1} = G_PKR_CR.qs{2} ).
  - wp.
    call S_keygen_equiv.
    by auto.
  (* The adversary produces the same forgery on both sides. *)
  seq 1 1 : (  ={glob S, glob A, RO.mp}
      /\ EUF_CMA_PKR.h{1} = G_PKR_CR.h{2}
      /\ EUF_CMA_PKR.sk{1} = G_PKR_CR.sk{2}
      /\ EUF_CMA_PKR.pk_h{1} = G_PKR_CR.pk_h{2}
      /\ EUF_CMA_PKR.qs{1} = G_PKR_CR.qs{2}
      /\ m{1} = m{2}
      /\ sig{1} = sig{2} ).
  - call (:  ={glob S, RO.mp}
        /\ EUF_CMA_PKR.h{1} = G_PKR_CR.h{2}
        /\ EUF_CMA_PKR.sk{1} = G_PKR_CR.sk{2}
        /\ EUF_CMA_PKR.pk_h{1} = G_PKR_CR.pk_h{2}
        /\ EUF_CMA_PKR.qs{1} = G_PKR_CR.qs{2}  ).
    by sim.
    by auto.
  (* Extract the signature components & synchronize the RO query. *)
  seq 2 2 : ( ={glob S, glob A, RO.mp}
      /\ EUF_CMA_PKR.h{1} = G_PKR_CR.h{2}
      /\ EUF_CMA_PKR.sk{1} = G_PKR_CR.sk{2}
      /\ EUF_CMA_PKR.pk_h{1} = G_PKR_CR.pk_h{2}
      /\ EUF_CMA_PKR.qs{1} = G_PKR_CR.qs{2}
      /\ m{1} = m{2}
      /\ sig{1} = sig{2}
      /\ r{1} = r{2}
      /\ s1{1} = s1{2}
      /\ s2{1} = s2{2}
      /\ c{1} = G_PKR_CR.c{2} ).
    call RO_hash_equiv.
    by auto.
  (* The right side computes h_rec, pk_rec and badCR.
     These variables do not affect PKR_Verify.verify. *)
  seq 0 2 : (   ={glob S, glob A, RO.mp}
      /\ EUF_CMA_PKR.pk_h{1} = G_PKR_CR.pk_h{2}
      /\ EUF_CMA_PKR.qs{1} = G_PKR_CR.qs{2}
        /\ m{1} = m{2}
      /\ sig{1} = sig{2} ).
  - by auto. print PKR_Verify.
    inline PKR_Verify.verify.
  wp.
  call RO_hash_equiv.
  by  auto.
  by  auto.
  by  auto.
qed.


 (* to prove Fundamental lemma, first we need to prove the game equivalence with bad event *)
local equiv G_PKR_CR_G_mid_ref :
  G_PKR_CR(S,A).main ~ G_mid_ref(S,A).main :
  ={glob S, glob A (*, RO.mp*)}
  ==>  (res{1} => res{2} \/ G_PKR_CR.badCR{1}) .
proof.
  proc.
  inline RO.init.
  seq 5 4 :( ={glob S, glob A, RO.mp}
     /\ G_PKR_CR.h{1} = G_mid_ref.h{2}
     /\ G_PKR_CR.sk{1} = G_mid_ref.sk{2}
     /\ G_PKR_CR.pk_h{1}= G_mid_ref.pk_h{2}
     /\ G_PKR_CR.qs{1}= G_mid_ref.qs{2}  ).
  wp.
  call S_keygen_equiv.
  by   auto.
  seq 1 1 : ( ={glob S, glob A, RO.mp}
     /\ G_PKR_CR.h{1}=G_mid_ref.h{2}
     /\ G_PKR_CR.pk_h{1}=G_mid_ref.pk_h{2}
     /\ G_PKR_CR.qs{1}=G_mid_ref.qs{2}
     /\ m{1}=m{2}
     /\ sig{1}=sig{2} ).
  call (: ={glob S, RO.mp}
     /\ G_PKR_CR.h{1}=G_mid_ref.h{2}
     /\ G_PKR_CR.sk{1}=G_mid_ref.sk{2}
     /\ G_PKR_CR.pk_h{1}=G_mid_ref.pk_h{2}
     /\ G_PKR_CR.qs{1}=G_mid_ref.qs{2} ).
       by  sim. by auto.
       inline RefVerify.verify.
     inline PKR_Verify.verify.
  seq 1 5 : (={glob S, glob A, RO.mp}
     /\ r{1} = sig{1}.`1
     /\ s1{1} = sig{1}.`2
     /\ s2{1} = sig{1}.`3
     /\ r0{2} = sig{2}.`1
     /\ s20{2} = sig{2}.`3
     /\ G_PKR_CR.h{1} = G_mid_ref.h{2}
     /\ G_PKR_CR.pk_h{1} = G_mid_ref.pk_h{2}
     /\ G_PKR_CR.qs{1} = G_mid_ref.qs{2}
     /\ m{1} = m{2}
     /\ sig{1} = sig{2}
     /\ r{1} = r0{2}
     /\ s1{1} = sig{2}.`2
     /\ s2{1} = s20{2}
      /\ pk{2} = G_mid_ref.h{2}
     /\ m0{2} = m{2}).
  wp. by auto.
  seq 1 1 : (
  ((glob S){1} = (glob S){2} /\ (glob A){1} = (glob A){2} /\ RO.mp{1} = RO.mp{2})
    /\ G_PKR_CR.h{1} = G_mid_ref.h{2}
    /\ G_PKR_CR.pk_h{1} = G_mid_ref.pk_h{2}
    /\ G_PKR_CR.qs{1} = G_mid_ref.qs{2}
    /\ m{1} = m{2}
    /\ sig{1} = sig{2}
    /\ r{1} = r0{2}
    /\ r{1} = sig{1}.`1
    /\ r0{2} = sig{2}.`1
    /\ s20{2} = sig{2}.`3
    /\ s1{1} = sig{2}.`2
    /\ s2{1} = s20{2}
    /\ pk{2} = G_mid_ref.h{2}
    /\ m0{2} = m{2}
    /\ G_PKR_CR.c{1} = c{2}
    /\ RO.mp{1}.[(r{1}, m{1})] = Some G_PKR_CR.c{1}
    /\ RO.mp{2}.[(r0{2}, m0{2})] = Some c{2} ).
    inline RO.hash.
    sp.
    if.
    - move=> &1 &2 Hpre.
    have Hkey : (r1{1}, m1{1}) = (r1{2}, m1{2}) by smt().
    have Hc0eq : c0{1} = c0{2} by smt().
    smt().
  wp.
  rnd.
  skip => &1 &2 Hpre Hx /=.
  move=> HxIn.
  split; first exact HxIn.
  have Hr1 : r1{1} = r1{2} by smt().
  have Hm1 : m1{1} = m1{2} by smt().
  have Hupd : RO.mp{1}.[r1{1}, m1{1} <- Hx] = RO.mp{2}.[r1{2}, m1{2} <- Hx]
  by smt().
  have HlkL : RO.mp{1}.[r1{1}, m1{1} <- Hx].[r{1}, m{1}] = Some Hx. smt.
  move=> _.
  have HkR : (r0{2}, m0{2}) = (r1{2}, m1{2}) by smt().
  have HlkR : RO.mp{2}.[r1{2}, m1{2} <- Hx].[r0{2}, m0{2}] = Some Hx.
  rewrite HkR.
  smt.
  smt().
  wp.
  skip => &1 &2 Hpre Hnn /=.
    have Hkey : (r1{1}, m1{1}) = (r1{2}, m1{2}) by smt().
    have Hc0eq : c0{1} = c0{2} by smt().
    have Hoget : oget c0{1} = oget c0{2} by smt().
    have Hsome1 : c0{1} = Some (oget c0{1}) by smt().
    have Hsome2 : c0{2} = Some (oget c0{2}) by smt().
    smt().
    (* *)
 seq 3 1 :(
  ((glob S){1} = (glob S){2} /\ (glob A){1} = (glob A){2} /\ RO.mp{1} = RO.mp{2})
    /\ G_PKR_CR.h{1} = G_mid_ref.h{2}
    /\ G_PKR_CR.pk_h{1} = G_mid_ref.pk_h{2}
    /\ G_PKR_CR.qs{1} = G_mid_ref.qs{2}
    /\ m{1} = m{2}
    /\ sig{1} = sig{2}
    /\ r{1} = r0{2}
    /\ r{1} = sig{1}.`1
    /\ s20{2} = sig{2}.`3
    /\ s1{1} = sig{2}.`2
    /\ s2{1} = s20{2}
    /\ pk{2} = G_mid_ref.h{2}
    /\ m0{2} = m{2}
    /\ G_PKR_CR.c{1} = c{2}
    /\ RO.mp{1}.[r{1}, m{1}] = Some G_PKR_CR.c{1}
    /\ RO.mp{2}.[r0{2}, m0{2}] = Some c{2}
    /\ G_PKR_CR.badCR{1} =
       (mulp (inv_p s2{1}) (subp G_PKR_CR.c{1} s1{1}) <> G_PKR_CR.h{1}
    /\ Hpk (mulp (inv_p s2{1}) (subp G_PKR_CR.c{1} s1{1})) = G_PKR_CR.pk_h{1})
    /\ b{2} = (norm_sq2 (subp c{2} (mulp s20{2} pk{2})) s20{2} <= beta_sq) ).
  wp. 
  by auto => />.
(*Consuming deterministic setup before second hash *)
  seq 4 0 : (
       ((glob S){1} = (glob S){2} /\ (glob A){1} = (glob A){2} /\ RO.mp{1} = RO.mp{2})
         /\ G_PKR_CR.h{1} = G_mid_ref.h{2}
         /\ G_PKR_CR.pk_h{1} = G_mid_ref.pk_h{2}
         /\ G_PKR_CR.qs{1} = G_mid_ref.qs{2}
         /\ m{1} = m{2}
         /\ sig{1} = sig{2}
         /\ r{1} = r0{2}
         /\ r{1} = sig{1}.`1
         /\ r0{2} = sig{2}.`1
         /\ s20{2} = sig{2}.`3
         /\ s1{1} = sig{2}.`2
         /\ s2{1} = s20{2}
         /\ pk{2} = G_mid_ref.h{2}
         /\ m0{2} = m{2}
         /\ G_PKR_CR.c{1} = c{2}
         /\ RO.mp{1}.[r{1}, m{1}] = Some G_PKR_CR.c{1}
         /\ RO.mp{2}.[r0{2}, m0{2}] = Some c{2}
         /\ G_PKR_CR.badCR{1} =
       (mulp (inv_p s2{1}) (subp G_PKR_CR.c{1} s1{1}) <> G_PKR_CR.h{1}
         /\ Hpk (mulp (inv_p s2{1}) (subp G_PKR_CR.c{1} s1{1})) = G_PKR_CR.pk_h{1})
         /\ b{2} = (norm_sq2 (subp c{2} (mulp s20{2} pk{2})) s20{2} <= beta_sq)
         /\ pk{1} = G_PKR_CR.pk_h{1}
         /\ m0{1} = m{1}
         /\ s{1} = sig{1}
         /\ (r0{1}, s10{1}, s20{1}) = sig{1} ).
   wp.
   skip => &1 &2 Hpre /=.
   smt().
  seq 1 0 :( ((glob S){1} = (glob S){2} /\ (glob A){1} = (glob A){2})
         /\ G_PKR_CR.h{1} = G_mid_ref.h{2}
         /\ G_PKR_CR.pk_h{1} = G_mid_ref.pk_h{2}
         /\ G_PKR_CR.qs{1} = G_mid_ref.qs{2}
         /\ m{1} = m{2}
         /\ sig{1} = sig{2}
         /\ r{1} = sig{1}.`1
         /\ r0{2} = sig{2}.`1
         /\ pk{2} = G_mid_ref.h{2}
         /\ pk{1} = G_PKR_CR.pk_h{1}
         /\ s10{1} = sig{1}.`2
         /\ s20{1} = sig{1}.`3
         /\ c{1} = G_PKR_CR.c{1}
         /\ c{1} = c{2}
         /\ s20{1} = s20{2}
         /\ b{2} = (norm_sq2 (subp c{2} (mulp s20{2} pk{2})) s20{2} <= beta_sq)
         /\ G_PKR_CR.badCR{1} =
       (mulp (inv_p s20{1}) (subp c{1} s10{1}) <> G_PKR_CR.h{1}
         /\ Hpk (mulp (inv_p s20{1}) (subp c{1} s10{1})) = pk{1})).
   - inline RO.hash.
    sp.
    wp 1 0.
    if{1}.
    - auto=> />.
  smt().
  skip => &1 &2 Hall Hnn /=.
(*auto=> /> &1 &2 Hpre Hnn. this made too weak*)
  have Hget : oget RO.mp{2}.[r0{1}, m{2}] = c{2}. smt(). 
  have Hc0some : c0{1} = Some G_PKR_CR.c{1}.
  have Hr1r : r1{1} = r{1} by smt().
  have Hm1m : m1{1} = m{1} by smt().
  have Hc0def : c0{1} = RO.mp{1}.[r1{1}, m1{1}] by smt().
  have Hmp : RO.mp{1}.[r{1}, m{1}] = Some G_PKR_CR.c{1} by smt().
  rewrite Hc0def Hr1r Hm1m.
  exact Hmp.
  have HnnG : Hnn = G_PKR_CR.c{1} by smt().
  have HnnC : Hnn = c{2} by smt().
  have Hs10 : s10{1} = s1{1} by smt().
  have Hs10sig : s10{1} = sig{1}.`2 by smt().
  have Hs20sig : s20{1} = sig{1}.`3 by smt().
  have Hs20sig1 : s20{1} = sig{1}.`3 by smt().
  have Hs2sig1  : s2{1}  = sig{1}.`3.  by smt().
  have Hs20s2   : s20{1} = s2{1} by smt().
  have Hbad :
  G_PKR_CR.badCR{1} =
  (mulp (inv_p s20{1}) (subp Hnn s10{1}) <> G_PKR_CR.h{1} /\
   Hpk (mulp (inv_p s20{1}) (subp Hnn s10{1})) = pk{1}).
  - rewrite HnnG Hs10 Hs20s2.
    smt().
  smt().
  seq 3 0 :(((glob S){1} = (glob S){2} /\ (glob A){1} = (glob A){2}) /\
  G_PKR_CR.h{1} = G_mid_ref.h{2} /\
  G_PKR_CR.pk_h{1} = G_mid_ref.pk_h{2} /\
  G_PKR_CR.qs{1} = G_mid_ref.qs{2} /\
  m{1} = m{2} /\
  sig{1} = sig{2} /\
  r{1} = sig{1}.`1 /\
  r0{2} = sig{2}.`1 /\
  pk{2} = G_mid_ref.h{2} /\
  pk{1} = G_PKR_CR.pk_h{1} /\
  s10{1} = sig{1}.`2 /\
  s20{1} = sig{1}.`3 /\
  c{1} = G_PKR_CR.c{1} /\
  c{1} = c{2} /\
  s20{1} = s20{2} /\
  b{2} = norm_sq2 (subp c{2} (mulp s20{2} pk{2})) s20{2} <= beta_sq /\
  G_PKR_CR.badCR{1} =
    (mulp (inv_p s20{1}) (subp c{1} s10{1}) <> G_PKR_CR.h{1} /\
     Hpk (mulp (inv_p s20{1}) (subp c{1} s10{1})) = pk{1}) /\
  b{1} =
    (invertible s20{1} /\
     Hpk (mulp (inv_p s20{1}) (subp c{1} s10{1})) = pk{1} /\
     norm_sq2 s10{1} s20{1} <= beta_sq) ).
 - wp.
 by  auto=> />.
 seq 0 0 : (b{1} /\ ! (m{1} \in G_PKR_CR.qs{1}) =>
   (b{2} /\ ! (m{2} \in G_mid_ref.qs{2})) \/ G_PKR_CR.badCR{1}).
 - auto=> />.
  move=> &2 Hinv Hnorm _.
  case (mulp (inv_p sig{2}.`3) (subp c{2} sig{2}.`2) = G_mid_ref.h{2}).
  - move=> Heq.
    left.
  have Hadd : addp sig{2}.`2 (mulp sig{2}.`3 G_mid_ref.h{2}) = c{2}.
  - have Htmp := pkr_conv sig{2}.`2 sig{2}.`3 G_mid_ref.h{2} c{2}.
  have := Htmp Hinv Heq.
  auto.
  have Hsub : subp c{2} (mulp sig{2}.`3 G_mid_ref.h{2}) = sig{2}.`2.
  - rewrite -Hadd add_comm.
  exact subp_cancel.
  rewrite Hsub.
  exact Hnorm.
  smt().
by auto. 
qed. 

local lemma step2_good &m :
 Pr[G_PKR_CR(S,A).main() @ &m :
      res /\ !G_PKR_CR.badCR]
 <=
 Pr[G_mid_ref(S,A).main() @ &m :
      res].
proof.
  byequiv G_PKR_CR_G_mid_ref.
  by auto.
  smt(). 
qed.

local lemma step2_split &m :
 Pr[G_PKR_CR(S,A).main() @ &m : res]
 <=
 Pr[G_PKR_CR(S,A).main() @ &m : res /\ !G_PKR_CR.badCR]
 +
 Pr[G_PKR_CR(S,A).main() @ &m : G_PKR_CR.badCR].
proof. 
have split_eq :
  Pr[G_PKR_CR(S,A).main() @ &m : res]
  = Pr[G_PKR_CR(S,A).main() @ &m : res /\ G_PKR_CR.badCR]
  + Pr[G_PKR_CR(S,A).main() @ &m : res /\ !G_PKR_CR.badCR].
  by rewrite Pr[mu_split G_PKR_CR.badCR].
have sub_le :
  Pr[G_PKR_CR(S,A).main() @ &m : res /\ G_PKR_CR.badCR]
  <= Pr[G_PKR_CR(S,A).main() @ &m : G_PKR_CR.badCR].
  by rewrite Pr[mu_sub] //; smt().
smt(). 
qed.

local lemma step2_fundamental &m :
 Pr[G_PKR_CR(S,A).main() @ &m : res]
 <=
 Pr[G_mid_ref(S,A).main() @ &m : res]
 +
 Pr[G_PKR_CR(S,A).main() @ &m : G_PKR_CR.badCR].
proof.
  have Hgood :=
    step2_good &m.
  have Hsplit :=
    step2_split &m.
  smt(). 
qed.

local equiv G_PKR_CR_CR :
  G_PKR_CR(S,A).main ~ CR_PKHash(Red_CR(S,A)).main :
  ={glob S, glob A, RO.mp}
  ==>
  G_PKR_CR.badCR{1} => res{2}.
proof.
  proc. 
  inline Red_CR(S,A).find. print CR_PKHash.
  seq 5 3 : (={glob S, glob A, RO.mp}
  /\ G_PKR_CR.h{1} = Red_CR.h{2}
  /\ G_PKR_CR.sk{1} = Red_CR.sk{2}
  /\ G_PKR_CR.pk_h{1} = pk_h{2}
  /\ G_PKR_CR.pk_h{1} = Hpk G_PKR_CR.h{1} ). 
  wp.
  call S_keygen_equiv.
  inline RO.init.
  - by auto. 
  seq 1 1 : (={glob S, glob A, RO.mp}
  /\ G_PKR_CR.h{1} = Red_CR.h{2}
  /\ G_PKR_CR.sk{1} = Red_CR.sk{2}
  /\ G_PKR_CR.pk_h{1} = pk_h{2}  /\ G_PKR_CR.pk_h{1} = Hpk G_PKR_CR.h{1}
  /\ G_PKR_CR.qs{1} = G_PKR_CR.qs{1}
  /\ m{1} = m{2}
  /\ sig{1} = sig{2}).
  call (:
  ={glob S, RO.mp}
    /\ G_PKR_CR.h{1} = Red_CR.h{2}
    /\ G_PKR_CR.sk{1} = Red_CR.sk{2}
    (*/\ G_PKR_CR.pk_h{1} = pk_h{2}*)  /\ G_PKR_CR.pk_h{1} = Hpk G_PKR_CR.h{1}
    /\ G_PKR_CR.qs{1} = G_PKR_CR.qs{1}).
 proc. 
 (* Synchronize S.sign on equal sk,m *)
 seq 1 1 :
  (m{1} = m{2}
   /\ (glob S){1} = (glob S){2}
   /\ RO.mp{1} = RO.mp{2}
   /\ G_PKR_CR.h{1} = Red_CR.h{2}
   /\ G_PKR_CR.sk{1} = Red_CR.sk{2}
   /\ r{1} = r{2}
   /\ s2{1} = s2{2}
   /\ G_PKR_CR.pk_h{1} = Hpk G_PKR_CR.h{1} ).
  - call S_sign_equiv.
  by  auto.
(* Synchronize RO.hash on equal (r,m) and equal RO.mp *)
 seq 1 1 : (m{1} = m{2}
   /\ (glob S){1} = (glob S){2}
   /\ RO.mp{1} = RO.mp{2}
   /\ G_PKR_CR.h{1} = Red_CR.h{2}
   /\ G_PKR_CR.sk{1} = Red_CR.sk{2}
   /\ G_PKR_CR.pk_h{1} = Hpk G_PKR_CR.h{1}
   /\ r{1} = r{2}
   /\ s2{1} = s2{2}
   /\ c0{1} = c{2}).
  - call RO_hash_equiv.
    by auto.
    by auto. 
    by auto.
  seq 2 2 : (((glob S){1} = (glob S){2}
   /\ (glob A){1} = (glob A){2} /\ RO.mp{1} = RO.mp{2})
   /\ G_PKR_CR.h{1} = Red_CR.h{2}
   /\ G_PKR_CR.sk{1} = Red_CR.sk{2}
   /\ G_PKR_CR.pk_h{1} = pk_h{2}
   /\ G_PKR_CR.pk_h{1} = pk_h{2}  /\ G_PKR_CR.pk_h{1} = Hpk G_PKR_CR.h{1}
   /\ m{1} = m{2}
   /\ sig{1} = sig{2}
   /\ r{1} = r{2}
   /\ s1{1} = s1{2}
   /\ s2{1} = s2{2}
   /\ G_PKR_CR.c{1} = c{2}).
  - call RO_hash_equiv.
  by  auto.
  seq 3 2 : (((glob S){1} = (glob S){2} /\
    (glob A){1} = (glob A){2} /\ RO.mp{1} = RO.mp{2})
   /\ G_PKR_CR.h{1} = Red_CR.h{2}
   /\ pk_h{2} = Hpk Red_CR.h{2}
   /\ m{1} = m{2}
   /\ sig{1} = sig{2}
   /\ r{1} = r{2}
   /\ s1{1} = s1{2}
   /\ s2{1} = s2{2}
   /\ G_PKR_CR.c{1} = c{2}
   /\ h1{2} = Red_CR.h{2}
   /\ h2{2} = mulp (inv_p s2{2}) (subp c{2} s1{2})
   /\ G_PKR_CR.badCR{1} =
      (h1{2} <> h2{2} /\ Hpk h1{2} = Hpk h2{2})).
    - wp.
      auto.
      smt(). 
 (* Prove target implication before final left verify call *)
  seq 0 0 :
    (G_PKR_CR.badCR{1} => h1{2} <> h2{2} /\ Hpk h1{2} = Hpk h2{2}). 
    skip. by  auto.  
  inline PKR_Verify.verify.
  wp.
  call{1} RO_hash_ll.
  wp. 
  by auto.
qed. 


lemma step3_CR &m :
 Pr[G_PKR_CR(S,A).main() @ &m : G_PKR_CR.badCR]
 <=
 Pr[CR_PKHash(Red_CR(S,A)).main() @ &m : res].
 proof.
  byequiv G_PKR_CR_CR.
  auto.
  smt().
qed.

  (*Reduction to standard Falcon! Now reduce to the ordinary EUF-CMA game. *)
local equiv O_sign_equiv :
  G_mid_ref(S,A).O.sign ~ Red2(S,A,EUF_CMA_Std(S,Red2(S,A)).O).SO.sign :
  ={glob S, RO.mp, arg}
    /\ G_mid_ref.h{1} = SimOracle.h_sim{2}
    /\ G_mid_ref.sk{1} = EUF_CMA_Std.sk{2}
    /\ G_mid_ref.qs{1} = EUF_CMA_Std.qs{2} ==>
  ={res, glob S, RO.mp}
    /\ G_mid_ref.h{1} = SimOracle.h_sim{2}
    /\ G_mid_ref.sk{1} = EUF_CMA_Std.sk{2}
    /\ G_mid_ref.qs{1} = EUF_CMA_Std.qs{2}.
proof.
  proc.
  inline EUF_CMA_Std(S,Red2(S,A)).O.sign.
  wp. call RO_hash_equiv.
  wp. call S_sign_equiv.
  by auto.
qed.

local lemma step4_std &m :
 Pr[G_mid_ref(S,A).main() @ &m : res]
 <=
 Pr[EUF_CMA_Std(S,Red2(S,A)).main() @ &m : res].
proof.
  byequiv (_ :
    ={glob S, glob A, RO.mp}
    ==> res{1} => res{2}).
  proc.
  inline RO.init.
  seq 4 3 : (={glob S, glob A, RO.mp}
     /\ G_mid_ref.h{1} = pk{2}
     /\ G_mid_ref.sk{1} = EUF_CMA_Std.sk{2}
     /\ G_mid_ref.pk_h{1} = Hpk pk{2}
     /\ G_mid_ref.qs{1} = EUF_CMA_Std.qs{2}).
  - wp.
   call S_keygen_equiv.
   by auto.
   inline Red2(S,A,EUF_CMA_Std(S,Red2(S,A)).O).forge.
   seq 0 3 :   ((glob S){1} = (glob S){2} /\
   (glob A){1} = (glob A){2} /\
   RO.mp{1} = RO.mp{2} /\
   G_mid_ref.h{1} = pk{2} /\
   SimOracle.h_sim{2} = pk{2} /\
   G_mid_ref.sk{1} = EUF_CMA_Std.sk{2} /\
   G_mid_ref.pk_h{1} = Hpk pk{2} /\
   pk_h{2} = Hpk pk{2} /\
   G_mid_ref.qs{1} = EUF_CMA_Std.qs{2}).
   - by auto.
  seq 1 1 :((glob S){1} = (glob S){2} /\
   (glob A){1} = (glob A){2} /\
   RO.mp{1} = RO.mp{2} /\
   G_mid_ref.h{1} = pk{2} /\
   SimOracle.h_sim{2} = pk{2} /\
   G_mid_ref.sk{1} = EUF_CMA_Std.sk{2} /\
   G_mid_ref.pk_h{1} = Hpk pk{2} /\
   G_mid_ref.qs{1} = EUF_CMA_Std.qs{2} /\
   m{1} = m0{2} /\ sig{1} = sig{2} ).
  call (: ={ glob S, RO.mp}
     /\ G_mid_ref.h{1} = SimOracle.h_sim{2}
     /\ G_mid_ref.sk{1} = EUF_CMA_Std.sk{2}
     /\ G_mid_ref.qs{1} = EUF_CMA_Std.qs{2} ).
  proc.
   inline EUF_CMA_Std(S, Red2(S, A)).O.sign.
   wp. call RO_hash_equiv.
   wp. call S_sign_equiv.
   by auto. by auto. 
 symmetry. call S_verify_matches_ref. 
  by auto.
  by auto.
  by auto. 
qed.

(* Main theorem: assembles step1a, step2_fundamental, step3_CR and
   step4_std into the paper's security claim--Falcon-PKR's EUF-CMA
   advantage is bounded by (standard Falcon's EUF-CMA advantage
   against reduction Red2) + (an adversary's advantage against Hpk's
   collision resistance via Red_CR). No security loss beyond these
   two well-understood assumptions. *)
lemma PKR_security &m :
 Pr[EUF_CMA_PKR(S,A).main() @ &m : res]
 <=
 Pr[EUF_CMA_Std(S,Red2(S,A)).main() @ &m : res]
 +
 Pr[CR_PKHash(Red_CR(S,A)).main() @ &m : res].
proof.
  rewrite step1a.
  have Hfund := step2_fundamental.
  have Hcr := step3_CR.
  have Hstd := step4_std.
  smt. 
qed.

(* ---------------------------------------------------------------------
   CORRECTNESS: honestly-generated PKR signatures always verify.

   Uses the real PKR_Verify (verifies against a pkHash, recovering
   h_rec = inv(s2)*(c-s1) and comparing Hpk(h_rec) to the stored
   hash), and the real Sig_T.keygen, which returns (h,sk) directly
   -- no separate pk_of projection is needed or assumed.
----------------------------------------------------------------- *)

  (* Completes S_sign_ll: signing never returns without an invertible s2,
  a fixed RO entry for (r,m0), and norm <= beta_sq.
  Encodes restart-loop guarantee as a black-box fact about S.sign. *)

axiom S_sign_norm_bound (h0 : poly) (sk0 : skey) (m0 : message) :
  hoare[ S.sign :
      arg = (sk0, m0)
      ==>
      invertible res.`2
      /\ RO.mp.[(res.`1, m0)] <> None
      /\ norm_sq2 (subp (oget RO.mp.[(res.`1, m0)]) (mulp res.`2 h0)) res.`2
         <= beta_sq ].

local lemma RO_hash_cached (r0 : salt) (m0 : message) (mp0 : (salt * message, poly) fmap) :
  hoare[ RO.hash :
      arg = (r0, m0) /\ RO.mp = mp0 /\ mp0.[(r0, m0)] <> None
      ==> res = oget mp0.[(r0, m0)] /\ RO.mp = mp0 ].
proof.
  proc. sp. if.
  - exfalso. smt().
  - skip. smt().
qed.

module RefSign (S : Sig_T) = {
  proc sign(h : poly, sk : skey, m : message) : sig_pkr = {
    var r, s2, c, s1;
    (r, s2) <@ S.sign(sk, m);
    c       <@ RO.hash(r, m);
    s1      <- subp c (mulp s2 h);
    return (r, s1, s2);
  }
}.

local lemma RefSign_norm_bound (h0 : poly) (sk0 : skey) (m0 : message) :
  hoare[ RefSign(S).sign :
      arg = (h0, sk0, m0) ==>
      exists c,
           RO.mp.[(res.`1,m0)] = Some c
        /\ invertible res.`3
        /\ addp res.`2 (mulp res.`3 h0) = c
        /\ norm_sq2 res.`2 res.`3 <= beta_sq ].
proof.
proc.
  seq 1 : (h = h0 /\ sk = sk0 /\ m = m0
          /\ invertible s2
          /\ RO.mp.[(r,m0)] <> None
          /\ norm_sq2 (subp (oget RO.mp.[(r,m0)]) (mulp s2 h0)) s2 <= beta_sq).
  - call (S_sign_norm_bound h0 sk0 m0).
    skip. smt().
  exlim r, RO.mp => rX mpX.
  seq 1 : (h = h0 /\ sk = sk0 /\ m = m0 /\ r = rX
          /\ invertible s2
          /\ mpX.[(rX,m0)] <> None
          /\ c = oget mpX.[(rX,m0)]
          /\ RO.mp = mpX
          /\ norm_sq2 (subp (oget mpX.[(rX,m0)]) (mulp s2 h0)) s2 <= beta_sq).
  - call (RO_hash_cached rX m0 mpX).
    skip. smt().
    wp. skip.
    move=> /> &hr Hinv Hmp Hnorm.
  exists (oget mpX.[(rX,m0)]). smt.
qed.

local lemma PKR_Verify_correct
    (pk0 : pkHash)
    (h0 : poly)
    (m0 : message)
    (r0 : salt)
    (s10 s20 c0 : poly) :
  hoare[ PKR_Verify.verify :
        arg = (pk0, m0, (r0,s10,s20))
     /\ pk0 = Hpk h0
     /\ RO.mp.[(r0,m0)] = Some c0
     /\ invertible s20
     /\ addp s10 (mulp s20 h0) = c0
     /\ norm_sq2 s10 s20 <= beta_sq
     ==> res ].
proof.
proc.
  sp. wp.
  exlim r, m, RO.mp => rX mX mpX.
  call (RO_hash_cached rX mX mpX).
  skip.
  move=> /> &hr Hpk0 Hmp.  
  split; [smt() |].
  move=> _. smt. 
qed.


(* Top-level honest-execution experiment: real keygen, honest sign
   via RefSign, verify via the real PKR_Verify against the hashed
   public key. *)
module PKR_Correctness (S : Sig_T) = {
  proc main(m : message) : bool = {
    var h, sk, pk_h, sig, b;
    RO.init();
    (h, sk) <@ S.keygen();
    pk_h    <- Hpk h;
    sig     <@ RefSign(S).sign(h, sk, m);
    b       <@ PKR_Verify.verify(pk_h, m, sig);
    return b;
  }
}.

(* Main correctness theorem: every honestly-generated Falcon-PKR
   signature verifies. Chains RefSign_norm_bound (honest signing
   satisfies the algebraic + norm preconditions) into
   PKR_Verify_correct (those preconditions imply acceptance). *)
local lemma PKR_correctness (m0 : message) :
  hoare[ PKR_Correctness(S).main : arg = m0 ==> res ].
proof.
proc.
  inline RO.init.
  seq 1 : (m = m0).
  - auto.
  seq 1 : (m = m0).
  - call (_: true ==> true); auto.
  exlim h, sk => hX skX.
  seq 1 : (m = m0 /\ h = hX /\ sk = skX /\ pk_h = Hpk hX).
  - auto.
  seq 1 : ( m = m0 /\ h = hX /\ pk_h = Hpk hX
          /\ exists c,
               RO.mp.[(sig.`1,m0)] = Some c
            /\ invertible sig.`3
            /\ addp sig.`2 (mulp sig.`3 hX) = c
            /\ norm_sq2 sig.`2 sig.`3 <= beta_sq ).
  - call (RefSign_norm_bound hX skX m0).
  skip. smt().
  exlim pk_h, m, sig.`1, sig.`2, sig.`3 => pkX mX rX s1X s2X.
  elim* => c0.
  call (PKR_Verify_correct pkX hX mX rX s1X s2X c0).
  skip. smt().
qed.

end section Security.


(*--------------ends here with CR modification-------------------- *)
  
  
  
