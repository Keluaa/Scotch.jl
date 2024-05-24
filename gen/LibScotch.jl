module LibScotch

using SCOTCH_jll
export SCOTCH_jll


const SCOTCH_Idx = Cint

const SCOTCH_Num = Cint

const SCOTCH_GraphPart2 = Cuchar

struct SCOTCH_Arch
    dummy::NTuple{11, Cdouble}
end

struct SCOTCH_ArchDom
    dummy::NTuple{5, Cdouble}
end

struct SCOTCH_Context
    dummy::NTuple{3, Cdouble}
end

struct SCOTCH_Geom
    dummy::NTuple{2, Cdouble}
end

struct SCOTCH_Graph
    dummy::NTuple{12, Cdouble}
end

struct SCOTCH_Mesh
    dummy::NTuple{15, Cdouble}
end

struct SCOTCH_Mapping
    dummy::NTuple{4, Cdouble}
end

struct SCOTCH_Ordering
    dummy::NTuple{17, Cdouble}
end

struct SCOTCH_Strat
    dummy::NTuple{1, Cdouble}
end

function SCOTCH_archAlloc()
    ccall((:SCOTCH_archAlloc, libscotch), Ptr{SCOTCH_Arch}, ())
end

function SCOTCH_archSizeof()
    ccall((:SCOTCH_archSizeof, libscotch), Cint, ())
end

function SCOTCH_archInit(arg1)
    ccall((:SCOTCH_archInit, libscotch), Cint, (Ptr{SCOTCH_Arch},), arg1)
end

function SCOTCH_archExit(arg1)
    ccall((:SCOTCH_archExit, libscotch), Cvoid, (Ptr{SCOTCH_Arch},), arg1)
end

function SCOTCH_archLoad(arg1, arg2)
    ccall((:SCOTCH_archLoad, libscotch), Cint, (Ptr{SCOTCH_Arch}, Ptr{Cint}), arg1, arg2)
end

function SCOTCH_archSave(arg1, arg2)
    ccall((:SCOTCH_archSave, libscotch), Cint, (Ptr{SCOTCH_Arch}, Ptr{Cint}), arg1, arg2)
end

function SCOTCH_archBuild(arg1, arg2, arg3, arg4, arg5)
    ccall((:SCOTCH_archBuild, libscotch), Cint, (Ptr{SCOTCH_Arch}, Ptr{SCOTCH_Graph}, SCOTCH_Num, Ptr{SCOTCH_Num}, Ptr{SCOTCH_Strat}), arg1, arg2, arg3, arg4, arg5)
end

function SCOTCH_archBuild0(arg1, arg2, arg3, arg4, arg5)
    ccall((:SCOTCH_archBuild0, libscotch), Cint, (Ptr{SCOTCH_Arch}, Ptr{SCOTCH_Graph}, SCOTCH_Num, Ptr{SCOTCH_Num}, Ptr{SCOTCH_Strat}), arg1, arg2, arg3, arg4, arg5)
end

function SCOTCH_archBuild2(arg1, arg2, arg3, arg4)
    ccall((:SCOTCH_archBuild2, libscotch), Cint, (Ptr{SCOTCH_Arch}, Ptr{SCOTCH_Graph}, SCOTCH_Num, Ptr{SCOTCH_Num}), arg1, arg2, arg3, arg4)
end

function SCOTCH_archName(arg1)
    ccall((:SCOTCH_archName, libscotch), Ptr{Cchar}, (Ptr{SCOTCH_Arch},), arg1)
end

function SCOTCH_archSize(arg1)
    ccall((:SCOTCH_archSize, libscotch), SCOTCH_Num, (Ptr{SCOTCH_Arch},), arg1)
end

function SCOTCH_archVar(arg1)
    ccall((:SCOTCH_archVar, libscotch), Cint, (Ptr{SCOTCH_Arch},), arg1)
end

function SCOTCH_archCmplt(arg1, arg2)
    ccall((:SCOTCH_archCmplt, libscotch), Cint, (Ptr{SCOTCH_Arch}, SCOTCH_Num), arg1, arg2)
end

function SCOTCH_archCmpltw(arg1, arg2, arg3)
    ccall((:SCOTCH_archCmpltw, libscotch), Cint, (Ptr{SCOTCH_Arch}, SCOTCH_Num, Ptr{SCOTCH_Num}), arg1, arg2, arg3)
end

function SCOTCH_archHcub(arg1, arg2)
    ccall((:SCOTCH_archHcub, libscotch), Cint, (Ptr{SCOTCH_Arch}, SCOTCH_Num), arg1, arg2)
end

function SCOTCH_archMesh2(arg1, arg2, arg3)
    ccall((:SCOTCH_archMesh2, libscotch), Cint, (Ptr{SCOTCH_Arch}, SCOTCH_Num, SCOTCH_Num), arg1, arg2, arg3)
end

function SCOTCH_archMesh3(arg1, arg2, arg3, arg4)
    ccall((:SCOTCH_archMesh3, libscotch), Cint, (Ptr{SCOTCH_Arch}, SCOTCH_Num, SCOTCH_Num, SCOTCH_Num), arg1, arg2, arg3, arg4)
end

function SCOTCH_archMeshX(arg1, arg2, arg3)
    ccall((:SCOTCH_archMeshX, libscotch), Cint, (Ptr{SCOTCH_Arch}, SCOTCH_Num, Ptr{SCOTCH_Num}), arg1, arg2, arg3)
end

function SCOTCH_archSub(arg1, arg2, arg3, arg4)
    ccall((:SCOTCH_archSub, libscotch), Cint, (Ptr{SCOTCH_Arch}, Ptr{SCOTCH_Arch}, SCOTCH_Num, Ptr{SCOTCH_Num}), arg1, arg2, arg3, arg4)
end

function SCOTCH_archTleaf(arg1, arg2, arg3, arg4)
    ccall((:SCOTCH_archTleaf, libscotch), Cint, (Ptr{SCOTCH_Arch}, SCOTCH_Num, Ptr{SCOTCH_Num}, Ptr{SCOTCH_Num}), arg1, arg2, arg3, arg4)
end

function SCOTCH_archTorus2(arg1, arg2, arg3)
    ccall((:SCOTCH_archTorus2, libscotch), Cint, (Ptr{SCOTCH_Arch}, SCOTCH_Num, SCOTCH_Num), arg1, arg2, arg3)
end

function SCOTCH_archTorus3(arg1, arg2, arg3, arg4)
    ccall((:SCOTCH_archTorus3, libscotch), Cint, (Ptr{SCOTCH_Arch}, SCOTCH_Num, SCOTCH_Num, SCOTCH_Num), arg1, arg2, arg3, arg4)
end

function SCOTCH_archTorusX(arg1, arg2, arg3)
    ccall((:SCOTCH_archTorusX, libscotch), Cint, (Ptr{SCOTCH_Arch}, SCOTCH_Num, Ptr{SCOTCH_Num}), arg1, arg2, arg3)
end

function SCOTCH_archVcmplt(arg1)
    ccall((:SCOTCH_archVcmplt, libscotch), Cint, (Ptr{SCOTCH_Arch},), arg1)
end

function SCOTCH_archVhcub(arg1)
    ccall((:SCOTCH_archVhcub, libscotch), Cint, (Ptr{SCOTCH_Arch},), arg1)
end

function SCOTCH_archDomAlloc()
    ccall((:SCOTCH_archDomAlloc, libscotch), Ptr{SCOTCH_ArchDom}, ())
end

function SCOTCH_archDomSizeof()
    ccall((:SCOTCH_archDomSizeof, libscotch), Cint, ())
end

function SCOTCH_archDomNum(arg1, arg2)
    ccall((:SCOTCH_archDomNum, libscotch), SCOTCH_Num, (Ptr{SCOTCH_Arch}, Ptr{SCOTCH_ArchDom}), arg1, arg2)
end

function SCOTCH_archDomTerm(arg1, arg2, arg3)
    ccall((:SCOTCH_archDomTerm, libscotch), Cint, (Ptr{SCOTCH_Arch}, Ptr{SCOTCH_ArchDom}, SCOTCH_Num), arg1, arg2, arg3)
end

function SCOTCH_archDomSize(arg1, arg2)
    ccall((:SCOTCH_archDomSize, libscotch), SCOTCH_Num, (Ptr{SCOTCH_Arch}, Ptr{SCOTCH_ArchDom}), arg1, arg2)
end

function SCOTCH_archDomWght(arg1, arg2)
    ccall((:SCOTCH_archDomWght, libscotch), SCOTCH_Num, (Ptr{SCOTCH_Arch}, Ptr{SCOTCH_ArchDom}), arg1, arg2)
end

function SCOTCH_archDomDist(arg1, arg2, arg3)
    ccall((:SCOTCH_archDomDist, libscotch), SCOTCH_Num, (Ptr{SCOTCH_Arch}, Ptr{SCOTCH_ArchDom}, Ptr{SCOTCH_ArchDom}), arg1, arg2, arg3)
end

function SCOTCH_archDomFrst(arg1, arg2)
    ccall((:SCOTCH_archDomFrst, libscotch), Cint, (Ptr{SCOTCH_Arch}, Ptr{SCOTCH_ArchDom}), arg1, arg2)
end

function SCOTCH_archDomBipart(arg1, arg2, arg3, arg4)
    ccall((:SCOTCH_archDomBipart, libscotch), Cint, (Ptr{SCOTCH_Arch}, Ptr{SCOTCH_ArchDom}, Ptr{SCOTCH_ArchDom}, Ptr{SCOTCH_ArchDom}), arg1, arg2, arg3, arg4)
end

function SCOTCH_contextAlloc()
    ccall((:SCOTCH_contextAlloc, libscotch), Ptr{SCOTCH_Context}, ())
end

function SCOTCH_contextInit(arg1)
    ccall((:SCOTCH_contextInit, libscotch), Cint, (Ptr{SCOTCH_Context},), arg1)
end

function SCOTCH_contextExit(arg1)
    ccall((:SCOTCH_contextExit, libscotch), Cvoid, (Ptr{SCOTCH_Context},), arg1)
end

function SCOTCH_contextOptionGetNum(arg1, arg2, arg3)
    ccall((:SCOTCH_contextOptionGetNum, libscotch), Cint, (Ptr{SCOTCH_Context}, Cint, Ptr{SCOTCH_Num}), arg1, arg2, arg3)
end

function SCOTCH_contextOptionSetNum(arg1, arg2, arg3)
    ccall((:SCOTCH_contextOptionSetNum, libscotch), Cint, (Ptr{SCOTCH_Context}, Cint, SCOTCH_Num), arg1, arg2, arg3)
end

function SCOTCH_contextOptionParse(arg1, arg2)
    ccall((:SCOTCH_contextOptionParse, libscotch), Cint, (Ptr{SCOTCH_Context}, Ptr{Cchar}), arg1, arg2)
end

function SCOTCH_contextRandomClone(arg1)
    ccall((:SCOTCH_contextRandomClone, libscotch), Cint, (Ptr{SCOTCH_Context},), arg1)
end

function SCOTCH_contextRandomReset(arg1)
    ccall((:SCOTCH_contextRandomReset, libscotch), Cvoid, (Ptr{SCOTCH_Context},), arg1)
end

function SCOTCH_contextRandomSeed(arg1, arg2)
    ccall((:SCOTCH_contextRandomSeed, libscotch), Cvoid, (Ptr{SCOTCH_Context}, SCOTCH_Num), arg1, arg2)
end

function SCOTCH_contextThreadImport1(arg1, arg2)
    ccall((:SCOTCH_contextThreadImport1, libscotch), Cint, (Ptr{SCOTCH_Context}, Cint), arg1, arg2)
end

function SCOTCH_contextThreadImport2(arg1, arg2)
    ccall((:SCOTCH_contextThreadImport2, libscotch), Cint, (Ptr{SCOTCH_Context}, Cint), arg1, arg2)
end

function SCOTCH_contextThreadSpawn(arg1, arg2, arg3)
    ccall((:SCOTCH_contextThreadSpawn, libscotch), Cint, (Ptr{SCOTCH_Context}, Cint, Ptr{Cint}), arg1, arg2, arg3)
end

function SCOTCH_contextBindGraph(arg1, arg2, arg3)
    ccall((:SCOTCH_contextBindGraph, libscotch), Cint, (Ptr{SCOTCH_Context}, Ptr{SCOTCH_Graph}, Ptr{SCOTCH_Graph}), arg1, arg2, arg3)
end

function SCOTCH_contextBindMesh(arg1, arg2, arg3)
    ccall((:SCOTCH_contextBindMesh, libscotch), Cint, (Ptr{SCOTCH_Context}, Ptr{SCOTCH_Mesh}, Ptr{SCOTCH_Mesh}), arg1, arg2, arg3)
end

function SCOTCH_errorProg(arg1)
    ccall((:SCOTCH_errorProg, libscotch), Cvoid, (Ptr{Cchar},), arg1)
end

function SCOTCH_geomAlloc()
    ccall((:SCOTCH_geomAlloc, libscotch), Ptr{SCOTCH_Geom}, ())
end

function SCOTCH_geomSizeof()
    ccall((:SCOTCH_geomSizeof, libscotch), Cint, ())
end

function SCOTCH_geomInit(arg1)
    ccall((:SCOTCH_geomInit, libscotch), Cint, (Ptr{SCOTCH_Geom},), arg1)
end

function SCOTCH_geomExit(arg1)
    ccall((:SCOTCH_geomExit, libscotch), Cvoid, (Ptr{SCOTCH_Geom},), arg1)
end

function SCOTCH_geomData(arg1, arg2, arg3)
    ccall((:SCOTCH_geomData, libscotch), Cvoid, (Ptr{SCOTCH_Geom}, Ptr{SCOTCH_Num}, Ptr{Ptr{Cdouble}}), arg1, arg2, arg3)
end

function SCOTCH_graphAlloc()
    ccall((:SCOTCH_graphAlloc, libscotch), Ptr{SCOTCH_Graph}, ())
end

function SCOTCH_graphSizeof()
    ccall((:SCOTCH_graphSizeof, libscotch), Cint, ())
end

function SCOTCH_graphInit(arg1)
    ccall((:SCOTCH_graphInit, libscotch), Cint, (Ptr{SCOTCH_Graph},), arg1)
end

function SCOTCH_graphExit(arg1)
    ccall((:SCOTCH_graphExit, libscotch), Cvoid, (Ptr{SCOTCH_Graph},), arg1)
end

function SCOTCH_graphFree(arg1)
    ccall((:SCOTCH_graphFree, libscotch), Cvoid, (Ptr{SCOTCH_Graph},), arg1)
end

function SCOTCH_graphLoad(arg1, arg2, arg3, arg4)
    ccall((:SCOTCH_graphLoad, libscotch), Cint, (Ptr{SCOTCH_Graph}, Ptr{Cint}, SCOTCH_Num, SCOTCH_Num), arg1, arg2, arg3, arg4)
end

function SCOTCH_graphSave(arg1, arg2)
    ccall((:SCOTCH_graphSave, libscotch), Cint, (Ptr{SCOTCH_Graph}, Ptr{Cint}), arg1, arg2)
end

function SCOTCH_graphBuild(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10)
    ccall((:SCOTCH_graphBuild, libscotch), Cint, (Ptr{SCOTCH_Graph}, SCOTCH_Num, SCOTCH_Num, Ptr{SCOTCH_Num}, Ptr{SCOTCH_Num}, Ptr{SCOTCH_Num}, Ptr{SCOTCH_Num}, SCOTCH_Num, Ptr{SCOTCH_Num}, Ptr{SCOTCH_Num}), arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10)
end

function SCOTCH_graphBase(arg1, arg2)
    ccall((:SCOTCH_graphBase, libscotch), SCOTCH_Num, (Ptr{SCOTCH_Graph}, SCOTCH_Num), arg1, arg2)
end

function SCOTCH_graphCheck(arg1)
    ccall((:SCOTCH_graphCheck, libscotch), Cint, (Ptr{SCOTCH_Graph},), arg1)
end

function SCOTCH_graphCoarsen(arg1, arg2, arg3, arg4, arg5, arg6)
    ccall((:SCOTCH_graphCoarsen, libscotch), Cint, (Ptr{SCOTCH_Graph}, SCOTCH_Num, Cdouble, SCOTCH_Num, Ptr{SCOTCH_Graph}, Ptr{SCOTCH_Num}), arg1, arg2, arg3, arg4, arg5, arg6)
end

function SCOTCH_graphCoarsenMatch(arg1, arg2, arg3, arg4, arg5)
    ccall((:SCOTCH_graphCoarsenMatch, libscotch), Cint, (Ptr{SCOTCH_Graph}, Ptr{SCOTCH_Num}, Cdouble, SCOTCH_Num, Ptr{SCOTCH_Num}), arg1, arg2, arg3, arg4, arg5)
end

function SCOTCH_graphCoarsenBuild(arg1, arg2, arg3, arg4, arg5)
    ccall((:SCOTCH_graphCoarsenBuild, libscotch), Cint, (Ptr{SCOTCH_Graph}, SCOTCH_Num, Ptr{SCOTCH_Num}, Ptr{SCOTCH_Graph}, Ptr{SCOTCH_Num}), arg1, arg2, arg3, arg4, arg5)
end

function SCOTCH_graphColor(arg1, arg2, arg3, arg4)
    ccall((:SCOTCH_graphColor, libscotch), Cint, (Ptr{SCOTCH_Graph}, Ptr{SCOTCH_Num}, Ptr{SCOTCH_Num}, SCOTCH_Num), arg1, arg2, arg3, arg4)
end

function SCOTCH_graphData(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10)
    ccall((:SCOTCH_graphData, libscotch), Cvoid, (Ptr{SCOTCH_Graph}, Ptr{SCOTCH_Num}, Ptr{SCOTCH_Num}, Ptr{Ptr{SCOTCH_Num}}, Ptr{Ptr{SCOTCH_Num}}, Ptr{Ptr{SCOTCH_Num}}, Ptr{Ptr{SCOTCH_Num}}, Ptr{SCOTCH_Num}, Ptr{Ptr{SCOTCH_Num}}, Ptr{Ptr{SCOTCH_Num}}), arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10)
end

function SCOTCH_graphSize(arg1, arg2, arg3)
    ccall((:SCOTCH_graphSize, libscotch), Cvoid, (Ptr{SCOTCH_Graph}, Ptr{SCOTCH_Num}, Ptr{SCOTCH_Num}), arg1, arg2, arg3)
end

function SCOTCH_graphStat(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15)
    ccall((:SCOTCH_graphStat, libscotch), Cvoid, (Ptr{SCOTCH_Graph}, Ptr{SCOTCH_Num}, Ptr{SCOTCH_Num}, Ptr{SCOTCH_Num}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{SCOTCH_Num}, Ptr{SCOTCH_Num}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{SCOTCH_Num}, Ptr{SCOTCH_Num}, Ptr{SCOTCH_Num}, Ptr{Cdouble}, Ptr{Cdouble}), arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15)
end

function SCOTCH_graphDiamPV(arg1)
    ccall((:SCOTCH_graphDiamPV, libscotch), SCOTCH_Num, (Ptr{SCOTCH_Graph},), arg1)
end

function SCOTCH_graphDump(arg1, arg2, arg3, arg4)
    ccall((:SCOTCH_graphDump, libscotch), Cint, (Ptr{SCOTCH_Graph}, Ptr{Cchar}, Ptr{Cchar}, Ptr{Cint}), arg1, arg2, arg3, arg4)
end

function SCOTCH_graphGeomLoadChac(arg1, arg2, arg3, arg4, arg5)
    ccall((:SCOTCH_graphGeomLoadChac, libscotch), Cint, (Ptr{SCOTCH_Graph}, Ptr{SCOTCH_Geom}, Ptr{Cint}, Ptr{Cint}, Ptr{Cchar}), arg1, arg2, arg3, arg4, arg5)
end

function SCOTCH_graphGeomLoadHabo(arg1, arg2, arg3, arg4, arg5)
    ccall((:SCOTCH_graphGeomLoadHabo, libscotch), Cint, (Ptr{SCOTCH_Graph}, Ptr{SCOTCH_Geom}, Ptr{Cint}, Ptr{Cint}, Ptr{Cchar}), arg1, arg2, arg3, arg4, arg5)
end

function SCOTCH_graphGeomLoadMmkt(arg1, arg2, arg3, arg4, arg5)
    ccall((:SCOTCH_graphGeomLoadMmkt, libscotch), Cint, (Ptr{SCOTCH_Graph}, Ptr{SCOTCH_Geom}, Ptr{Cint}, Ptr{Cint}, Ptr{Cchar}), arg1, arg2, arg3, arg4, arg5)
end

function SCOTCH_graphGeomLoadScot(arg1, arg2, arg3, arg4, arg5)
    ccall((:SCOTCH_graphGeomLoadScot, libscotch), Cint, (Ptr{SCOTCH_Graph}, Ptr{SCOTCH_Geom}, Ptr{Cint}, Ptr{Cint}, Ptr{Cchar}), arg1, arg2, arg3, arg4, arg5)
end

function SCOTCH_graphGeomSaveChac(arg1, arg2, arg3, arg4, arg5)
    ccall((:SCOTCH_graphGeomSaveChac, libscotch), Cint, (Ptr{SCOTCH_Graph}, Ptr{SCOTCH_Geom}, Ptr{Cint}, Ptr{Cint}, Ptr{Cchar}), arg1, arg2, arg3, arg4, arg5)
end

function SCOTCH_graphGeomSaveMmkt(arg1, arg2, arg3, arg4, arg5)
    ccall((:SCOTCH_graphGeomSaveMmkt, libscotch), Cint, (Ptr{SCOTCH_Graph}, Ptr{SCOTCH_Geom}, Ptr{Cint}, Ptr{Cint}, Ptr{Cchar}), arg1, arg2, arg3, arg4, arg5)
end

function SCOTCH_graphGeomSaveScot(arg1, arg2, arg3, arg4, arg5)
    ccall((:SCOTCH_graphGeomSaveScot, libscotch), Cint, (Ptr{SCOTCH_Graph}, Ptr{SCOTCH_Geom}, Ptr{Cint}, Ptr{Cint}, Ptr{Cchar}), arg1, arg2, arg3, arg4, arg5)
end

function SCOTCH_graphInduceList(arg1, arg2, arg3, arg4)
    ccall((:SCOTCH_graphInduceList, libscotch), Cint, (Ptr{SCOTCH_Graph}, SCOTCH_Num, Ptr{SCOTCH_Num}, Ptr{SCOTCH_Graph}), arg1, arg2, arg3, arg4)
end

function SCOTCH_graphInducePart(arg1, arg2, arg3, arg4, arg5)
    ccall((:SCOTCH_graphInducePart, libscotch), Cint, (Ptr{SCOTCH_Graph}, SCOTCH_Num, Ptr{SCOTCH_GraphPart2}, SCOTCH_GraphPart2, Ptr{SCOTCH_Graph}), arg1, arg2, arg3, arg4, arg5)
end

function SCOTCH_graphMapInit(arg1, arg2, arg3, arg4)
    ccall((:SCOTCH_graphMapInit, libscotch), Cint, (Ptr{SCOTCH_Graph}, Ptr{SCOTCH_Mapping}, Ptr{SCOTCH_Arch}, Ptr{SCOTCH_Num}), arg1, arg2, arg3, arg4)
end

function SCOTCH_graphMapExit(arg1, arg2)
    ccall((:SCOTCH_graphMapExit, libscotch), Cvoid, (Ptr{SCOTCH_Graph}, Ptr{SCOTCH_Mapping}), arg1, arg2)
end

function SCOTCH_graphMapLoad(arg1, arg2, arg3)
    ccall((:SCOTCH_graphMapLoad, libscotch), Cint, (Ptr{SCOTCH_Graph}, Ptr{SCOTCH_Mapping}, Ptr{Cint}), arg1, arg2, arg3)
end

function SCOTCH_graphMapSave(arg1, arg2, arg3)
    ccall((:SCOTCH_graphMapSave, libscotch), Cint, (Ptr{SCOTCH_Graph}, Ptr{SCOTCH_Mapping}, Ptr{Cint}), arg1, arg2, arg3)
end

function SCOTCH_graphMapCompute(arg1, arg2, arg3)
    ccall((:SCOTCH_graphMapCompute, libscotch), Cint, (Ptr{SCOTCH_Graph}, Ptr{SCOTCH_Mapping}, Ptr{SCOTCH_Strat}), arg1, arg2, arg3)
end

function SCOTCH_graphMapFixedCompute(arg1, arg2, arg3)
    ccall((:SCOTCH_graphMapFixedCompute, libscotch), Cint, (Ptr{SCOTCH_Graph}, Ptr{SCOTCH_Mapping}, Ptr{SCOTCH_Strat}), arg1, arg2, arg3)
end

function SCOTCH_graphMap(arg1, arg2, arg3, arg4)
    ccall((:SCOTCH_graphMap, libscotch), Cint, (Ptr{SCOTCH_Graph}, Ptr{SCOTCH_Arch}, Ptr{SCOTCH_Strat}, Ptr{SCOTCH_Num}), arg1, arg2, arg3, arg4)
end

function SCOTCH_graphMapFixed(arg1, arg2, arg3, arg4)
    ccall((:SCOTCH_graphMapFixed, libscotch), Cint, (Ptr{SCOTCH_Graph}, Ptr{SCOTCH_Arch}, Ptr{SCOTCH_Strat}, Ptr{SCOTCH_Num}), arg1, arg2, arg3, arg4)
end

function SCOTCH_graphMapView(arg1, arg2, arg3)
    ccall((:SCOTCH_graphMapView, libscotch), Cint, (Ptr{SCOTCH_Graph}, Ptr{SCOTCH_Mapping}, Ptr{Cint}), arg1, arg2, arg3)
end

function SCOTCH_graphPart(arg1, arg2, arg3, arg4)
    ccall((:SCOTCH_graphPart, libscotch), Cint, (Ptr{SCOTCH_Graph}, SCOTCH_Num, Ptr{SCOTCH_Strat}, Ptr{SCOTCH_Num}), arg1, arg2, arg3, arg4)
end

function SCOTCH_graphPartFixed(arg1, arg2, arg3, arg4)
    ccall((:SCOTCH_graphPartFixed, libscotch), Cint, (Ptr{SCOTCH_Graph}, SCOTCH_Num, Ptr{SCOTCH_Strat}, Ptr{SCOTCH_Num}), arg1, arg2, arg3, arg4)
end

function SCOTCH_graphPartOvl(arg1, arg2, arg3, arg4)
    ccall((:SCOTCH_graphPartOvl, libscotch), Cint, (Ptr{SCOTCH_Graph}, SCOTCH_Num, Ptr{SCOTCH_Strat}, Ptr{SCOTCH_Num}), arg1, arg2, arg3, arg4)
end

function SCOTCH_graphPartOvlView(arg1, arg2, arg3, arg4)
    ccall((:SCOTCH_graphPartOvlView, libscotch), Cint, (Ptr{SCOTCH_Graph}, SCOTCH_Num, Ptr{SCOTCH_Num}, Ptr{Cint}), arg1, arg2, arg3, arg4)
end

function SCOTCH_graphRemap(arg1, arg2, arg3, arg4, arg5, arg6, arg7)
    ccall((:SCOTCH_graphRemap, libscotch), Cint, (Ptr{SCOTCH_Graph}, Ptr{SCOTCH_Arch}, Ptr{SCOTCH_Num}, Cdouble, Ptr{SCOTCH_Num}, Ptr{SCOTCH_Strat}, Ptr{SCOTCH_Num}), arg1, arg2, arg3, arg4, arg5, arg6, arg7)
end

function SCOTCH_graphRemapFixed(arg1, arg2, arg3, arg4, arg5, arg6, arg7)
    ccall((:SCOTCH_graphRemapFixed, libscotch), Cint, (Ptr{SCOTCH_Graph}, Ptr{SCOTCH_Arch}, Ptr{SCOTCH_Num}, Cdouble, Ptr{SCOTCH_Num}, Ptr{SCOTCH_Strat}, Ptr{SCOTCH_Num}), arg1, arg2, arg3, arg4, arg5, arg6, arg7)
end

function SCOTCH_graphRemapCompute(arg1, arg2, arg3, arg4, arg5, arg6)
    ccall((:SCOTCH_graphRemapCompute, libscotch), Cint, (Ptr{SCOTCH_Graph}, Ptr{SCOTCH_Mapping}, Ptr{SCOTCH_Mapping}, Cdouble, Ptr{SCOTCH_Num}, Ptr{SCOTCH_Strat}), arg1, arg2, arg3, arg4, arg5, arg6)
end

function SCOTCH_graphRemapFixedCompute(arg1, arg2, arg3, arg4, arg5, arg6)
    ccall((:SCOTCH_graphRemapFixedCompute, libscotch), Cint, (Ptr{SCOTCH_Graph}, Ptr{SCOTCH_Mapping}, Ptr{SCOTCH_Mapping}, Cdouble, Ptr{SCOTCH_Num}, Ptr{SCOTCH_Strat}), arg1, arg2, arg3, arg4, arg5, arg6)
end

function SCOTCH_graphRemapView(arg1, arg2, arg3, arg4, arg5, arg6)
    ccall((:SCOTCH_graphRemapView, libscotch), Cint, (Ptr{SCOTCH_Graph}, Ptr{SCOTCH_Mapping}, Ptr{SCOTCH_Mapping}, Cdouble, Ptr{SCOTCH_Num}, Ptr{Cint}), arg1, arg2, arg3, arg4, arg5, arg6)
end

function SCOTCH_graphRemapViewRaw(arg1, arg2, arg3, arg4, arg5, arg6)
    ccall((:SCOTCH_graphRemapViewRaw, libscotch), Cint, (Ptr{SCOTCH_Graph}, Ptr{SCOTCH_Mapping}, Ptr{SCOTCH_Mapping}, Cdouble, Ptr{SCOTCH_Num}, Ptr{Cint}), arg1, arg2, arg3, arg4, arg5, arg6)
end

function SCOTCH_graphRepart(arg1, arg2, arg3, arg4, arg5, arg6, arg7)
    ccall((:SCOTCH_graphRepart, libscotch), Cint, (Ptr{SCOTCH_Graph}, SCOTCH_Num, Ptr{SCOTCH_Num}, Cdouble, Ptr{SCOTCH_Num}, Ptr{SCOTCH_Strat}, Ptr{SCOTCH_Num}), arg1, arg2, arg3, arg4, arg5, arg6, arg7)
end

function SCOTCH_graphRepartFixed(arg1, arg2, arg3, arg4, arg5, arg6, arg7)
    ccall((:SCOTCH_graphRepartFixed, libscotch), Cint, (Ptr{SCOTCH_Graph}, SCOTCH_Num, Ptr{SCOTCH_Num}, Cdouble, Ptr{SCOTCH_Num}, Ptr{SCOTCH_Strat}, Ptr{SCOTCH_Num}), arg1, arg2, arg3, arg4, arg5, arg6, arg7)
end

function SCOTCH_graphTabLoad(arg1, arg2, arg3)
    ccall((:SCOTCH_graphTabLoad, libscotch), Cint, (Ptr{SCOTCH_Graph}, Ptr{SCOTCH_Num}, Ptr{Cint}), arg1, arg2, arg3)
end

function SCOTCH_graphTabSave(arg1, arg2, arg3)
    ccall((:SCOTCH_graphTabSave, libscotch), Cint, (Ptr{SCOTCH_Graph}, Ptr{SCOTCH_Num}, Ptr{Cint}), arg1, arg2, arg3)
end

function SCOTCH_graphOrderInit(arg1, arg2, arg3, arg4, arg5, arg6, arg7)
    ccall((:SCOTCH_graphOrderInit, libscotch), Cint, (Ptr{SCOTCH_Graph}, Ptr{SCOTCH_Ordering}, Ptr{SCOTCH_Num}, Ptr{SCOTCH_Num}, Ptr{SCOTCH_Num}, Ptr{SCOTCH_Num}, Ptr{SCOTCH_Num}), arg1, arg2, arg3, arg4, arg5, arg6, arg7)
end

function SCOTCH_graphOrderExit(arg1, arg2)
    ccall((:SCOTCH_graphOrderExit, libscotch), Cvoid, (Ptr{SCOTCH_Graph}, Ptr{SCOTCH_Ordering}), arg1, arg2)
end

function SCOTCH_graphOrderLoad(arg1, arg2, arg3)
    ccall((:SCOTCH_graphOrderLoad, libscotch), Cint, (Ptr{SCOTCH_Graph}, Ptr{SCOTCH_Ordering}, Ptr{Cint}), arg1, arg2, arg3)
end

function SCOTCH_graphOrderSave(arg1, arg2, arg3)
    ccall((:SCOTCH_graphOrderSave, libscotch), Cint, (Ptr{SCOTCH_Graph}, Ptr{SCOTCH_Ordering}, Ptr{Cint}), arg1, arg2, arg3)
end

function SCOTCH_graphOrderSaveMap(arg1, arg2, arg3)
    ccall((:SCOTCH_graphOrderSaveMap, libscotch), Cint, (Ptr{SCOTCH_Graph}, Ptr{SCOTCH_Ordering}, Ptr{Cint}), arg1, arg2, arg3)
end

function SCOTCH_graphOrderSaveTree(arg1, arg2, arg3)
    ccall((:SCOTCH_graphOrderSaveTree, libscotch), Cint, (Ptr{SCOTCH_Graph}, Ptr{SCOTCH_Ordering}, Ptr{Cint}), arg1, arg2, arg3)
end

function SCOTCH_graphOrderCompute(arg1, arg2, arg3)
    ccall((:SCOTCH_graphOrderCompute, libscotch), Cint, (Ptr{SCOTCH_Graph}, Ptr{SCOTCH_Ordering}, Ptr{SCOTCH_Strat}), arg1, arg2, arg3)
end

function SCOTCH_graphOrderComputeList(arg1, arg2, arg3, arg4, arg5)
    ccall((:SCOTCH_graphOrderComputeList, libscotch), Cint, (Ptr{SCOTCH_Graph}, Ptr{SCOTCH_Ordering}, SCOTCH_Num, Ptr{SCOTCH_Num}, Ptr{SCOTCH_Strat}), arg1, arg2, arg3, arg4, arg5)
end

function SCOTCH_graphOrder(arg1, arg2, arg3, arg4, arg5, arg6, arg7)
    ccall((:SCOTCH_graphOrder, libscotch), Cint, (Ptr{SCOTCH_Graph}, Ptr{SCOTCH_Strat}, Ptr{SCOTCH_Num}, Ptr{SCOTCH_Num}, Ptr{SCOTCH_Num}, Ptr{SCOTCH_Num}, Ptr{SCOTCH_Num}), arg1, arg2, arg3, arg4, arg5, arg6, arg7)
end

function SCOTCH_graphOrderList(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
    ccall((:SCOTCH_graphOrderList, libscotch), Cint, (Ptr{SCOTCH_Graph}, SCOTCH_Num, Ptr{SCOTCH_Num}, Ptr{SCOTCH_Strat}, Ptr{SCOTCH_Num}, Ptr{SCOTCH_Num}, Ptr{SCOTCH_Num}, Ptr{SCOTCH_Num}, Ptr{SCOTCH_Num}), arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
end

function SCOTCH_graphOrderCheck(arg1, arg2)
    ccall((:SCOTCH_graphOrderCheck, libscotch), Cint, (Ptr{SCOTCH_Graph}, Ptr{SCOTCH_Ordering}), arg1, arg2)
end

function SCOTCH_mapAlloc()
    ccall((:SCOTCH_mapAlloc, libscotch), Ptr{SCOTCH_Mapping}, ())
end

function SCOTCH_mapSizeof()
    ccall((:SCOTCH_mapSizeof, libscotch), Cint, ())
end

function SCOTCH_memFree(arg1)
    ccall((:SCOTCH_memFree, libscotch), Cvoid, (Ptr{Cvoid},), arg1)
end

function SCOTCH_memCur()
    ccall((:SCOTCH_memCur, libscotch), SCOTCH_Idx, ())
end

function SCOTCH_memMax()
    ccall((:SCOTCH_memMax, libscotch), SCOTCH_Idx, ())
end

function SCOTCH_meshAlloc()
    ccall((:SCOTCH_meshAlloc, libscotch), Ptr{SCOTCH_Mesh}, ())
end

function SCOTCH_meshSizeof()
    ccall((:SCOTCH_meshSizeof, libscotch), Cint, ())
end

function SCOTCH_meshInit(arg1)
    ccall((:SCOTCH_meshInit, libscotch), Cint, (Ptr{SCOTCH_Mesh},), arg1)
end

function SCOTCH_meshExit(arg1)
    ccall((:SCOTCH_meshExit, libscotch), Cvoid, (Ptr{SCOTCH_Mesh},), arg1)
end

function SCOTCH_meshLoad(arg1, arg2, arg3)
    ccall((:SCOTCH_meshLoad, libscotch), Cint, (Ptr{SCOTCH_Mesh}, Ptr{Cint}, SCOTCH_Num), arg1, arg2, arg3)
end

function SCOTCH_meshSave(arg1, arg2)
    ccall((:SCOTCH_meshSave, libscotch), Cint, (Ptr{SCOTCH_Mesh}, Ptr{Cint}), arg1, arg2)
end

function SCOTCH_meshBuild(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12)
    ccall((:SCOTCH_meshBuild, libscotch), Cint, (Ptr{SCOTCH_Mesh}, SCOTCH_Num, SCOTCH_Num, SCOTCH_Num, SCOTCH_Num, Ptr{SCOTCH_Num}, Ptr{SCOTCH_Num}, Ptr{SCOTCH_Num}, Ptr{SCOTCH_Num}, Ptr{SCOTCH_Num}, SCOTCH_Num, Ptr{SCOTCH_Num}), arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12)
end

function SCOTCH_meshCheck(arg1)
    ccall((:SCOTCH_meshCheck, libscotch), Cint, (Ptr{SCOTCH_Mesh},), arg1)
end

function SCOTCH_meshSize(arg1, arg2, arg3, arg4)
    ccall((:SCOTCH_meshSize, libscotch), Cvoid, (Ptr{SCOTCH_Mesh}, Ptr{SCOTCH_Num}, Ptr{SCOTCH_Num}, Ptr{SCOTCH_Num}), arg1, arg2, arg3, arg4)
end

function SCOTCH_meshData(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13)
    ccall((:SCOTCH_meshData, libscotch), Cvoid, (Ptr{SCOTCH_Mesh}, Ptr{SCOTCH_Num}, Ptr{SCOTCH_Num}, Ptr{SCOTCH_Num}, Ptr{SCOTCH_Num}, Ptr{Ptr{SCOTCH_Num}}, Ptr{Ptr{SCOTCH_Num}}, Ptr{Ptr{SCOTCH_Num}}, Ptr{Ptr{SCOTCH_Num}}, Ptr{Ptr{SCOTCH_Num}}, Ptr{SCOTCH_Num}, Ptr{Ptr{SCOTCH_Num}}, Ptr{SCOTCH_Num}), arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13)
end

function SCOTCH_meshStat(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14)
    ccall((:SCOTCH_meshStat, libscotch), Cvoid, (Ptr{SCOTCH_Mesh}, Ptr{SCOTCH_Num}, Ptr{SCOTCH_Num}, Ptr{SCOTCH_Num}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{SCOTCH_Num}, Ptr{SCOTCH_Num}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{SCOTCH_Num}, Ptr{SCOTCH_Num}, Ptr{Cdouble}, Ptr{Cdouble}), arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14)
end

function SCOTCH_meshGraph(arg1, arg2)
    ccall((:SCOTCH_meshGraph, libscotch), Cint, (Ptr{SCOTCH_Mesh}, Ptr{SCOTCH_Graph}), arg1, arg2)
end

function SCOTCH_meshGraphDual(arg1, arg2, arg3)
    ccall((:SCOTCH_meshGraphDual, libscotch), Cint, (Ptr{SCOTCH_Mesh}, Ptr{SCOTCH_Graph}, SCOTCH_Num), arg1, arg2, arg3)
end

function SCOTCH_meshGeomLoadHabo(arg1, arg2, arg3, arg4, arg5)
    ccall((:SCOTCH_meshGeomLoadHabo, libscotch), Cint, (Ptr{SCOTCH_Mesh}, Ptr{SCOTCH_Geom}, Ptr{Cint}, Ptr{Cint}, Ptr{Cchar}), arg1, arg2, arg3, arg4, arg5)
end

function SCOTCH_meshGeomLoadScot(arg1, arg2, arg3, arg4, arg5)
    ccall((:SCOTCH_meshGeomLoadScot, libscotch), Cint, (Ptr{SCOTCH_Mesh}, Ptr{SCOTCH_Geom}, Ptr{Cint}, Ptr{Cint}, Ptr{Cchar}), arg1, arg2, arg3, arg4, arg5)
end

function SCOTCH_meshGeomSaveScot(arg1, arg2, arg3, arg4, arg5)
    ccall((:SCOTCH_meshGeomSaveScot, libscotch), Cint, (Ptr{SCOTCH_Mesh}, Ptr{SCOTCH_Geom}, Ptr{Cint}, Ptr{Cint}, Ptr{Cchar}), arg1, arg2, arg3, arg4, arg5)
end

function SCOTCH_meshOrderInit(arg1, arg2, arg3, arg4, arg5, arg6, arg7)
    ccall((:SCOTCH_meshOrderInit, libscotch), Cint, (Ptr{SCOTCH_Mesh}, Ptr{SCOTCH_Ordering}, Ptr{SCOTCH_Num}, Ptr{SCOTCH_Num}, Ptr{SCOTCH_Num}, Ptr{SCOTCH_Num}, Ptr{SCOTCH_Num}), arg1, arg2, arg3, arg4, arg5, arg6, arg7)
end

function SCOTCH_meshOrderExit(arg1, arg2)
    ccall((:SCOTCH_meshOrderExit, libscotch), Cvoid, (Ptr{SCOTCH_Mesh}, Ptr{SCOTCH_Ordering}), arg1, arg2)
end

function SCOTCH_meshOrderSave(arg1, arg2, arg3)
    ccall((:SCOTCH_meshOrderSave, libscotch), Cint, (Ptr{SCOTCH_Mesh}, Ptr{SCOTCH_Ordering}, Ptr{Cint}), arg1, arg2, arg3)
end

function SCOTCH_meshOrderSaveMap(arg1, arg2, arg3)
    ccall((:SCOTCH_meshOrderSaveMap, libscotch), Cint, (Ptr{SCOTCH_Mesh}, Ptr{SCOTCH_Ordering}, Ptr{Cint}), arg1, arg2, arg3)
end

function SCOTCH_meshOrderSaveTree(arg1, arg2, arg3)
    ccall((:SCOTCH_meshOrderSaveTree, libscotch), Cint, (Ptr{SCOTCH_Mesh}, Ptr{SCOTCH_Ordering}, Ptr{Cint}), arg1, arg2, arg3)
end

function SCOTCH_meshOrderCompute(arg1, arg2, arg3)
    ccall((:SCOTCH_meshOrderCompute, libscotch), Cint, (Ptr{SCOTCH_Mesh}, Ptr{SCOTCH_Ordering}, Ptr{SCOTCH_Strat}), arg1, arg2, arg3)
end

function SCOTCH_meshOrderComputeList(arg1, arg2, arg3, arg4, arg5)
    ccall((:SCOTCH_meshOrderComputeList, libscotch), Cint, (Ptr{SCOTCH_Mesh}, Ptr{SCOTCH_Ordering}, SCOTCH_Num, Ptr{SCOTCH_Num}, Ptr{SCOTCH_Strat}), arg1, arg2, arg3, arg4, arg5)
end

function SCOTCH_meshOrder(arg1, arg2, arg3, arg4, arg5, arg6, arg7)
    ccall((:SCOTCH_meshOrder, libscotch), Cint, (Ptr{SCOTCH_Mesh}, Ptr{SCOTCH_Strat}, Ptr{SCOTCH_Num}, Ptr{SCOTCH_Num}, Ptr{SCOTCH_Num}, Ptr{SCOTCH_Num}, Ptr{SCOTCH_Num}), arg1, arg2, arg3, arg4, arg5, arg6, arg7)
end

function SCOTCH_meshOrderList(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
    ccall((:SCOTCH_meshOrderList, libscotch), Cint, (Ptr{SCOTCH_Mesh}, SCOTCH_Num, Ptr{SCOTCH_Num}, Ptr{SCOTCH_Strat}, Ptr{SCOTCH_Num}, Ptr{SCOTCH_Num}, Ptr{SCOTCH_Num}, Ptr{SCOTCH_Num}, Ptr{SCOTCH_Num}), arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
end

function SCOTCH_meshOrderCheck(arg1, arg2)
    ccall((:SCOTCH_meshOrderCheck, libscotch), Cint, (Ptr{SCOTCH_Mesh}, Ptr{SCOTCH_Ordering}), arg1, arg2)
end

function SCOTCH_numSizeof()
    ccall((:SCOTCH_numSizeof, libscotch), Cint, ())
end

function SCOTCH_orderAlloc()
    ccall((:SCOTCH_orderAlloc, libscotch), Ptr{SCOTCH_Ordering}, ())
end

function SCOTCH_orderSizeof()
    ccall((:SCOTCH_orderSizeof, libscotch), Cint, ())
end

function SCOTCH_randomLoad(arg1)
    ccall((:SCOTCH_randomLoad, libscotch), Cint, (Ptr{Cint},), arg1)
end

function SCOTCH_randomSave(arg1)
    ccall((:SCOTCH_randomSave, libscotch), Cint, (Ptr{Cint},), arg1)
end

function SCOTCH_randomProc(arg1)
    ccall((:SCOTCH_randomProc, libscotch), Cvoid, (Cint,), arg1)
end

function SCOTCH_randomReset()
    ccall((:SCOTCH_randomReset, libscotch), Cvoid, ())
end

function SCOTCH_randomSeed(arg1)
    ccall((:SCOTCH_randomSeed, libscotch), Cvoid, (SCOTCH_Num,), arg1)
end

function SCOTCH_randomVal(arg1)
    ccall((:SCOTCH_randomVal, libscotch), SCOTCH_Num, (SCOTCH_Num,), arg1)
end

function SCOTCH_stratAlloc()
    ccall((:SCOTCH_stratAlloc, libscotch), Ptr{SCOTCH_Strat}, ())
end

function SCOTCH_stratSizeof()
    ccall((:SCOTCH_stratSizeof, libscotch), Cint, ())
end

function SCOTCH_stratInit(arg1)
    ccall((:SCOTCH_stratInit, libscotch), Cint, (Ptr{SCOTCH_Strat},), arg1)
end

function SCOTCH_stratExit(arg1)
    ccall((:SCOTCH_stratExit, libscotch), Cvoid, (Ptr{SCOTCH_Strat},), arg1)
end

function SCOTCH_stratFree(arg1)
    ccall((:SCOTCH_stratFree, libscotch), Cvoid, (Ptr{SCOTCH_Strat},), arg1)
end

function SCOTCH_stratSave(arg1, arg2)
    ccall((:SCOTCH_stratSave, libscotch), Cint, (Ptr{SCOTCH_Strat}, Ptr{Cint}), arg1, arg2)
end

function SCOTCH_stratGraphBipart(arg1, arg2)
    ccall((:SCOTCH_stratGraphBipart, libscotch), Cint, (Ptr{SCOTCH_Strat}, Ptr{Cchar}), arg1, arg2)
end

function SCOTCH_stratGraphMap(arg1, arg2)
    ccall((:SCOTCH_stratGraphMap, libscotch), Cint, (Ptr{SCOTCH_Strat}, Ptr{Cchar}), arg1, arg2)
end

function SCOTCH_stratGraphMapBuild(arg1, arg2, arg3, arg4)
    ccall((:SCOTCH_stratGraphMapBuild, libscotch), Cint, (Ptr{SCOTCH_Strat}, SCOTCH_Num, SCOTCH_Num, Cdouble), arg1, arg2, arg3, arg4)
end

function SCOTCH_stratGraphClusterBuild(arg1, arg2, arg3, arg4, arg5)
    ccall((:SCOTCH_stratGraphClusterBuild, libscotch), Cint, (Ptr{SCOTCH_Strat}, SCOTCH_Num, SCOTCH_Num, Cdouble, Cdouble), arg1, arg2, arg3, arg4, arg5)
end

function SCOTCH_stratGraphPartOvl(arg1, arg2)
    ccall((:SCOTCH_stratGraphPartOvl, libscotch), Cint, (Ptr{SCOTCH_Strat}, Ptr{Cchar}), arg1, arg2)
end

function SCOTCH_stratGraphPartOvlBuild(arg1, arg2, arg3, arg4)
    ccall((:SCOTCH_stratGraphPartOvlBuild, libscotch), Cint, (Ptr{SCOTCH_Strat}, SCOTCH_Num, SCOTCH_Num, Cdouble), arg1, arg2, arg3, arg4)
end

function SCOTCH_stratGraphOrder(arg1, arg2)
    ccall((:SCOTCH_stratGraphOrder, libscotch), Cint, (Ptr{SCOTCH_Strat}, Ptr{Cchar}), arg1, arg2)
end

function SCOTCH_stratGraphOrderBuild(arg1, arg2, arg3, arg4)
    ccall((:SCOTCH_stratGraphOrderBuild, libscotch), Cint, (Ptr{SCOTCH_Strat}, SCOTCH_Num, SCOTCH_Num, Cdouble), arg1, arg2, arg3, arg4)
end

function SCOTCH_stratMeshOrder(arg1, arg2)
    ccall((:SCOTCH_stratMeshOrder, libscotch), Cint, (Ptr{SCOTCH_Strat}, Ptr{Cchar}), arg1, arg2)
end

function SCOTCH_stratMeshOrderBuild(arg1, arg2, arg3)
    ccall((:SCOTCH_stratMeshOrderBuild, libscotch), Cint, (Ptr{SCOTCH_Strat}, SCOTCH_Num, Cdouble), arg1, arg2, arg3)
end

function SCOTCH_version(arg1, arg2, arg3)
    ccall((:SCOTCH_version, libscotch), Cvoid, (Ptr{Cint}, Ptr{Cint}, Ptr{Cint}), arg1, arg2, arg3)
end

# Skipping MacroDefinition: SCOTCH_NUMMAX ( ( int ) ( ( ( unsigned int ) 1 << ( ( sizeof ( int ) << 3 ) - 1 ) ) - 1 ) )

const SCOTCH_NUMSTRING = "%d"

const SCOTCH_VERSION = 7

const SCOTCH_RELEASE = 0

const SCOTCH_PATCHLEVEL = 4

const SCOTCH_OPTIONNUMDETERMINISTIC = 0

const SCOTCH_OPTIONNUMRANDOMFIXEDSEED = 1

const SCOTCH_OPTIONNUMNBR = 2

const SCOTCH_COARSENNONE = 0x0000

const SCOTCH_COARSENFOLD = 0x0100

const SCOTCH_COARSENFOLDDUP = 0x0300

const SCOTCH_COARSENNOMERGE = 0x4000

const SCOTCH_STRATDEFAULT = 0x00000000

const SCOTCH_STRATQUALITY = 0x00000001

const SCOTCH_STRATSPEED = 0x00000002

const SCOTCH_STRATBALANCE = 0x00000004

const SCOTCH_STRATSAFETY = 0x00000008

const SCOTCH_STRATSCALABILITY = 0x00000010

const SCOTCH_STRATRECURSIVE = 0x00000100

const SCOTCH_STRATREMAP = 0x00000200

const SCOTCH_STRATLEVELMAX = 0x00001000

const SCOTCH_STRATLEVELMIN = 0x00002000

const SCOTCH_STRATLEAFSIMPLE = 0x00004000

const SCOTCH_STRATSEPASIMPLE = 0x00008000

const SCOTCH_STRATDISCONNECTED = 0x00010000

# exports
const PREFIXES = ["SCOTCH_"]
for name in names(@__MODULE__; all=true), prefix in PREFIXES
    if startswith(string(name), prefix)
        @eval export $name
    end
end

end # module
