/* 
    Copyright 2016--2019 Joshua Maglione, James B. Wilson.
    Distributed under MIT License.
*/


/*
  Under-the-hood slicing functions. Every function requires as input a sequence
  of ring elements and a sequence of integers at the very minimum. No checks are
  done, so be careful!
*/

// s: seq of elements in K, dims: seq of dims of frame [V_vav, ..., V_0], grid: sequence of subsets of {1..dim(V_a)}. 
__GetSlice := function( s, dims, grid )
  Grid := CartesianProduct(grid);
  offsets := [ &*dims[i+1..#dims] : i in [1..#dims-1] ] cat [1];
	indices := [ 1 + (&+[offsets[i]*(coord[i]-1): i in [1..#dims]]) : coord in Grid ];
	return s[indices];
end function;

// s: seq of elements in K, dims: seq of dims of frame [V_vav, ..., V_0], a: integer (in {0..vav})
__GetFoliation := function( s, dims, a )
  slice := [ {1..d} : d in dims ];
  i := #dims - a;
  F := [];
  for k in [1..dims[i]] do
    kSlice := slice;
    kSlice[i] := {k};
    Append(~F, __GetSlice(s, dims, kSlice));
  end for;
  return Matrix(F);
end function;

// The inverse of __GetFoliation. Namely, __ReverseFoliation(__GetFoliation(s, dims, a), dims, a) == s.
__ReverseFoliation := function( M, dims, a )
  v := #dims;
  i := v - a;
  d := &*(dims[i+1..#dims] cat [1]);
  return &cat[Eltseq(ExtractBlock(M, 1, j, Nrows(M), d)) : j in [1..Ncols(M) by d]];
end function;

// s: seq of elements in K, dims: seq of dims of frame [V_vav, ..., V_0], m: max, n: min (m,n in {0..vav})
__GetForms := function( s, dims, m, n : op := false )
  v := #dims;
  m := v-m;
  n := v-n;
  K := Parent(s[1]);
  if dims[m] eq dims[n] then
    M := MatrixAlgebra(K,dims[m]);
  else
    M := RMatrixSpace(K,dims[m],dims[n]);
  end if;
  Forms := [];
  CP := CartesianProduct( < [1..dims[k]] : k in Remove(Remove([1..#dims],n),m) > );
  for cp in CP do
    grid := [ {y} : y in Insert(Insert([ k : k in cp ],m,0),n,0) ];
    grid[m] := {1..dims[m]};
    grid[n] := {1..dims[n]};
    if op then
      Append(~Forms, Transpose(M!__GetSlice(s, dims, grid)));
    else
      Append(~Forms, M!__GetSlice(s, dims, grid));
    end if;
  end for;
  return Forms;
end function;

// s: seq of elements in K, dims: seq of dims of frame [V_vav, ..., V_0], g: permutation in Sym({0..vav}). 
__GetShuffle := function( s, dims, g )
  perm := Reverse([#dims-i : i in Eltseq(g)]);
  perm_inv := Reverse([#dims-i : i in Eltseq(g^-1)]);
  dims_old := dims;
  dims := dims[perm];
  CP := CartesianProduct(< [1..d] : d in dims >);
  offsets_old := [&*dims_old[i+1..#dims] : i in [1..#dims-1]] cat [1]; 
  indices := [1 + &+[offsets_old[i]*(cp[perm_inv[i]]-1): i in [1..#dims]] : cp in CP];
  return s[indices];
end function;

