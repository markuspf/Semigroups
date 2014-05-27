#############################################################################
###
##W  factor.gd
##Y  Copyright (C) 2013-14                                James D. Mitchell
###
###  Licensing information can be found in the README file of this package.
###
##############################################################################
###

DeclareOperation("MinimalFactorization", [IsSemigroup and IsFinite, IsAssociativeElement]);
DeclareOperation("Factorization", [IsLambdaOrb, IsPosInt, IsPerm]);
DeclareOperation("Factorization", [IsSemigroup, IsAssociativeElement]);
DeclareOperation("TraceSchreierTreeForward", [IsSemigroupData, IsPosInt]);
