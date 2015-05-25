/*
 * Semigroups GAP package
 *
 * This file contains converters from GAP to C++ elements and back.
 *
 */

#include "converter.h"
#include "types.h"

/*******************************************************************************
 * Bipartitions
*******************************************************************************/

Bipartition* BipartConverter::convert (Obj o, size_t n) {
  assert(IS_BIPART(o));
  assert(IsbPRec(o, RNamName("blocks")));

  Obj blocks = ElmPRec(o, RNamName("blocks"));
  PLAIN_LIST(blocks);

  assert((size_t) LEN_PLIST(blocks) == n);

  auto x = new Bipartition(n);
  for (u_int32_t i = 0; i < n; i++) {
    x->set(i, INT_INTOBJ(ELM_PLIST(blocks, i + 1)) - 1);
  }
  return x;
}

Obj BipartConverter::unconvert (Bipartition* x) {
  Obj o = NEW_PLIST(T_PLIST_CYC, x->degree());
  SET_LEN_PLIST(o, x->degree());
  for (u_int32_t i = 0; i < x->degree(); i++) {
    SET_ELM_PLIST(o, i + 1, INTOBJ_INT(x->at(i) + 1));
  }
  o = CALL_1ARGS(BipartitionByIntRepNC, o);
  return o;
}

/*******************************************************************************
 * Boolean matrices
*******************************************************************************/

BooleanMat* BoolMatConverter::convert (Obj o, size_t n) {
  assert(IS_BOOL_MAT(o));
  assert(LEN_PLIST(o) > 0);
  assert(IS_BLIST_REP(ELM_PLIST(o, 1)));
  assert(sqrt(n) == LEN_BLIST(ELM_PLIST(o, 1)));

  auto x = new BooleanMat(n);
  n = LEN_BLIST(ELM_PLIST(o, 1));
  for (size_t i = 0; i < n; i++) {
    Obj row = ELM_PLIST(o, i + 1);
    assert(IS_BLIST_REP(row));
    for (size_t j = 0; j < n; j++) {
      if (ELM_BLIST(row, j + 1) == True) {
        x->set(i * n + j, true);
      } else {
        x->set(i * n + j, false);
      }
    }
  }
  return x;
}

Obj BoolMatConverter::unconvert (BooleanMat* x) {
  size_t n = sqrt(x->degree());
  Obj o = NEW_PLIST(T_PLIST, n);
  SET_LEN_PLIST(o, n);

  for (size_t i = 0; i < n; i++) {
    Obj blist = NewBag(T_BLIST, SIZE_PLEN_BLIST(n));
    SET_LEN_BLIST(blist, n);
    for (size_t j = 0; j < n; j++) {
      if (x->at(i * n + j)) {
        SET_ELM_BLIST(blist, j + 1, True);
      } else {
        SET_ELM_BLIST(blist, j + 1, False);
      }
    }
    SET_ELM_PLIST(o, i + 1, blist);
    CHANGED_BAG(o);
  }
  return CALL_2ARGS(Objectify, BooleanMatType, o);
}

/*******************************************************************************
 * Matrices over semirings 
*******************************************************************************/

MatrixOverSemiring* MatrixOverSemiringConverter::convert (Obj o, size_t n) {
  assert(IS_MAT_OVER_SEMI_RING(o));
  assert(LEN_PLIST(o) > 0);
  assert(IS_PLIST(ELM_PLIST(o, 1)));
  assert(sqrt(n) == LEN_PLIST(ELM_PLIST(o, 1)));

  auto x = new MatrixOverSemiring(n, _semiring);
  n = LEN_PLIST(ELM_PLIST(o, 1));
  for (size_t i = 0; i < n; i++) {
    Obj row = ELM_PLIST(o, i + 1);
    for (size_t j = 0; j < n; j++) {
      Obj entry = ELM_PLIST(row, j + 1);
      if (EQ(_gap_zero, entry)) {
        x->set(i * n + j, _semiring->zero());
      } else {
        x->set(i * n + j, INT_INTOBJ(entry));
      }
    }
  }
  return x;
}

Obj MatrixOverSemiringConverter::unconvert (MatrixOverSemiring* x) {
  size_t n = sqrt(x->degree());
  Obj plist = NEW_PLIST(T_PLIST, n + 2);
  SET_LEN_PLIST(plist, n + 2);
  SET_ELM_PLIST(plist, n + 1, INTOBJ_INT(_semiring->threshold()));
  SET_ELM_PLIST(plist, n + 2, INTOBJ_INT(_semiring->period()));

  for (size_t i = 0; i < n; i++) {
    Obj row = NEW_PLIST(T_PLIST_CYC, n);
    SET_LEN_PLIST(row, n);
    for (size_t j = 0; j < n; j++) {
      long entry = x->at(i * n + j);
      if (entry == _semiring->zero()) {
        SET_ELM_PLIST(row, j + 1, _gap_zero);
      } else {
        SET_ELM_PLIST(row, j + 1, INTOBJ_INT(entry));
      }
    }
    SET_ELM_PLIST(plist, i + 1, row);
    CHANGED_BAG(plist);
  }
  return CALL_2ARGS(Objectify, _gap_type, plist);
}

/*******************************************************************************
 * Matrices over prime field
*******************************************************************************/

MatrixOverSemiring* MatrixOverPrimeFieldConverter::convert (Obj o, size_t n) {
  assert(IS_MAT_OVER_PF(o));
  assert(LEN_PLIST(o) > 0);
  assert(IS_PLIST(ELM_PLIST(o, 1)));
  assert(sqrt(n) == LEN_PLIST(ELM_PLIST(o, 1)));

  auto x = new MatrixOverSemiring(n, _field);
  n = LEN_PLIST(ELM_PLIST(o, 1));
  for (size_t i = 0; i < n; i++) {
    Obj row = ELM_PLIST(o, i + 1);
    for (size_t j = 0; j < n; j++) {
      FFV entry = VAL_FFE(ELM_PLIST(row, j + 1));
      x->set(i * n + j, entry);
    }
  }
  return x;
}

Obj MatrixOverPrimeFieldConverter::unconvert (MatrixOverSemiring* x) {
  size_t n = sqrt(x->degree());
  Obj plist = NEW_PLIST(T_PLIST, n);
  SET_LEN_PLIST(plist, n);

  for (size_t i = 0; i < n; i++) {
    Obj row = NEW_PLIST(T_PLIST_CYC, n);
    SET_LEN_PLIST(row, n);
    for (size_t j = 0; j < n; j++) {
      long entry = x->at(i * n + j);
      SET_ELM_PLIST(row, j + 1, INTOBJ_INT(x->at(i * n + j)));
    }
    SET_ELM_PLIST(plist, i + 1, row);
    CHANGED_BAG(plist);
  }
  return CALL_2ARGS(AsMatrixOverPrimeFieldNC, INTOBJ_INT(_field->size()), plist);
}

/*******************************************************************************
 * Partitioned binary relations (PBRs)
*******************************************************************************/

// TODO add some more asserts here

PartitionedBinaryRelation* PBRConverter::convert (Obj o, size_t n) {
  assert(IS_PBR(o));
  assert(n / 2 == (size_t) INT_INTOBJ(ELM_PLIST(o, 1)));

  std::vector<std::unordered_set<u_int32_t>*> pbr;
  pbr.reserve(n);

  for (u_int32_t i = 0; i < n; i++) {
    Obj adj = ELM_PLIST(o, i + 2);
    auto next = new std::unordered_set<u_int32_t>();
    for (u_int32_t j = 1; j <= LEN_PLIST(adj); j++) {
      next->insert(INT_INTOBJ(ELM_PLIST(adj, j)) - 1);
      // assumes that adj is duplicate-free
    }
    pbr.push_back(next);
  }
  return new PartitionedBinaryRelation(pbr);
}

Obj PBRConverter::unconvert (PartitionedBinaryRelation* x) {
  Obj plist = NEW_PLIST(T_PLIST_TAB, x->degree() + 1);
  SET_LEN_PLIST(plist, x->degree() + 1);
  SET_ELM_PLIST(plist, 1, INTOBJ_INT(x->degree() / 2));
  for (u_int32_t i = 0; i < x->degree(); i++) {
    size_t m = x->at(i)->size();
    Obj adj = NEW_PLIST(T_PLIST_CYC, m);
    SET_LEN_PLIST(adj, m);
    size_t j = 2;
    for (auto it = x->at(i)->cbegin(); it != x->at(i)->cend(); it++) { 
      SET_ELM_PLIST(adj, j++, INTOBJ_INT((*it) + 1));
    }
    SET_ELM_PLIST(plist, i + 2, adj);
    CHANGED_BAG(plist);
  }
  return CALL_2ARGS(Objectify, PartitionedBinaryRelationType, plist);
}
