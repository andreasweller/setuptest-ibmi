/*
-- 
-- Objektverwendungen Benutzung ermitteln mit Boardmitteln der IBM i
-- 27.04.2022, Dirk Neumann, www.POW3R.info, angepasst: PKS Software GmbH, A.Weller
-- 
*/

set schema VFPO;

call qsys2.qcmdexc('DSPPGMREF PGM(*ALL/DA02010*) OUTPUT(*OUTFILE) OUTFILE(QTEMP/PGMREF01)');

select WHLIB, WHPNAM, SUM(DSPCOUNT) as DSPCOUNTSUM, SUM(PRTFCOUNT) AS PRTFCOUNTSUM from (
	select WHLIB, WHPNAM, 1 AS DSPCOUNT, 0 AS PRTFCOUNT from QTEMP.PGMREF01 F1
	left join TABLE(QSYS2.OBJECT_STATISTICS('VFPO', '*ALL')) F2 
	on F1.WHLNAM = F2.OBJLIB and F1.WHFNAM = F2.OBJNAME and F1.WHOTYP = F2.OBJTYPE 
	where WHOBJT = 'F' and F2.OBJATTRIBUTE = 'DSPF'
	union
	select WHLIB, WHPNAM, 1 AS DSPCOUNT, 0 AS PRTFCOUNT from QTEMP.PGMREF01 F1
	left join TABLE(QSYS2.OBJECT_STATISTICS('VFPO', '*ALL')) F2 
	on F1.WHLNAM = F2.OBJLIB and F1.WHFNAM = F2.OBJNAME and F1.WHOTYP = F2.OBJTYPE 
	where WHOBJT = 'F' and F2.OBJATTRIBUTE = 'PRTF')
	group by WHLIB, WHPNAM
	order by WHLIB, WHPNAM;
	
	