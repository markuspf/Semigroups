#############################################################################
##
#W  attributes.tst
#Y  Copyright (C) 2015                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##
gap> START_TEST("Semigroups package: attributes.tst");
gap> LoadPackage("semigroups", false);;

#
gap> SemigroupsStartTest();

#T# AttributesTest1: MultiplicativeZero
# for a transformation semigroup/ideal
gap> t := Transformation( [ 1 ] );;

# MultiplicativeZero for T_1 (previously this crashed)
# See issue #121 on Bitbucket
gap> s := Semigroup(t); # with displaying the semigroup
<trivial transformation group>
gap> MultiplicativeZero(s) = t;
true
gap> s := Semigroup(t);; # not displaying the semigroup
gap> MultiplicativeZero(s) = t;
true

# MultiplicativeZero for trivial transformation monoid with different rep.
gap> t := Transformation( [ 2, 2, 3, 3 ] );;
gap> s := Semigroup(t); # with displaying the semigroup
<commutative transformation semigroup on 4 pts with 1 generator>
gap> MultiplicativeZero(s) = t;
true
gap> s := Semigroup(t);; # not displaying the semigroup
gap> MultiplicativeZero(s) = t;
true

# MultiplicativeZero: issue #121 on Bitbucket
gap> s := Semigroup([
> Transformation( [ 1, 2, 1 ] ),
> Transformation( [ 1, 2, 2 ] ) ]);;
gap> MultiplicativeZero(s);
fail
gap> ForAny(s, x -> IsMultiplicativeZero(s, x));
false

# MultiplicativeZero for a transformation semigroup ideal
gap> s := Semigroup([
> Transformation( [ 2, 3, 4, 1 ] ),
> Transformation( [ 2, 1, 3, 4 ] ),
> Transformation( [ 3, 1, 1, 3 ] ) ]);
<transformation semigroup on 4 pts with 3 generators>
gap> t := Transformation( [ 1, 1, 1, 1 ] );;
gap> I := SemigroupIdeal(s, t);
<regular transformation semigroup ideal on 4 pts with 1 generator>
gap> HasMultiplicativeZero(s);
false
gap> MultiplicativeZero(I); # does not know whether parent has a zero
fail
gap> HasMultiplicativeZero(s);
true
gap> MultiplicativeZero(s);
fail
gap> I := SemigroupIdeal(s, t);
<regular transformation semigroup ideal on 4 pts with 1 generator>
gap> MultiplicativeZero(I); # does know whether parent has a zero
fail

#T# AttributesTest2: MultiplicativeZero
# for a partial perm semigroup/ideal
gap> t := PartialPerm( [  ], [  ] );;

# MultiplicativeZero for S = { <empty mapping> }
gap> s := Semigroup(t);;
gap> MultiplicativeZero(s) = t;
true

# MultiplicativeZero for other trivial partial perm semigroups
gap> t := PartialPerm( [ 2, 4 ], [ 2, 4 ] );;
gap> s := Semigroup(t);;
gap> MultiplicativeZero(s) = t;
true

# MultiplicativeZero for a partial perm semigroup ideal
gap> s := Semigroup([
> PartialPerm( [ 1, 2, 3, 4 ], [ 2, 3, 4, 1 ] ),
> PartialPerm( [ 1, 2, 3, 4 ], [ 2, 1, 3, 4 ] ),
> PartialPerm( [ 1, 3 ], [ 2, 3 ] ) ]); 
<partial perm semigroup on 4 pts with 3 generators>
gap> t := PartialPerm( [  ], [  ] );;
gap> I := SemigroupIdeal(s, t);
<inverse partial perm semigroup ideal on 4 pts with 1 generator>
gap> HasMultiplicativeZero(s);
false
gap> MultiplicativeZero(I) = t; # does not know whether parent has a zero
true
gap> HasMultiplicativeZero(s);
true
gap> MultiplicativeZero(s) = t;
true
gap> I := SemigroupIdeal(s, t);
<inverse partial perm semigroup ideal on 4 pts with 1 generator>
gap> MultiplicativeZero(I) = t; # does know whether parent has a zero
true

#T# SEMIGROUPS_UnbindVariables
gap> Unbind(s);
gap> Unbind(t);
gap> Unbind(I);

#E#
gap> STOP_TEST( "Semigroups package: attributes.tst");

