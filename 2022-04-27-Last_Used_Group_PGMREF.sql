/*
-- 
-- Objektverwendungen Benutzung ermitteln mit Boardmitteln der IBM i
-- 27.04.2022, Dirk Neumann, www.POW3R.info, angepasst: PKS Software GmbH, A.Weller
-- 
*/

set schema VFPO;

call qsys2.qcmdexc('DSPPGMREF PGM(*ALL/DA07020R) OUTPUT(*OUTFILE) OUTFILE(QTEMP/PGMREF01)');

select age_used_group, age_created_group, count(*) as PGMCOUNT from (
   select DISTINCT WHPNAM, F4.LAST_USED_TIMESTAMP, F4.OBJCREATED,
    (case when F4.LAST_USED_TIMESTAMP > CURRENT_TIMESTAMP - 30 days then '01-USED-NEW30' else
       (case when F4.LAST_USED_TIMESTAMP > CURRENT_TIMESTAMP - 90 days then '02-USED-NEW90' else
          (case when F4.LAST_USED_TIMESTAMP > CURRENT_TIMESTAMP - 400 days then '03-USED-MEDIUM400' else
             (case when F4.LAST_USED_TIMESTAMP > CURRENT_TIMESTAMP - 750 days then '03-USED-MEDIUM750' else
             '04-USED-OLD'
             end)
          end)
       end)
    end)
    AS AGE_USED_GROUP,
    (case when F4.OBJCREATED > CURRENT_TIMESTAMP - 30 days then '01-CREATED-NEW30' else
       (case when F4.OBJCREATED > CURRENT_TIMESTAMP - 90 days then '02-CREATED-NEW90' else
          (case when F4.OBJCREATED > CURRENT_TIMESTAMP - 400 days then '03-CREATED-MEDIUM400' else
             (case when F4.OBJCREATED > CURRENT_TIMESTAMP - 750 days then '03-CREATED-MEDIUM750' else
             '04-CREATED-OLD'
             end)
          end)
       end)
    end)
    AS AGE_CREATED_GROUP
    from (
          SELECT * FROM QTEMP.PGMREF01 F1
            LEFT JOIN TABLE(QSYS2.OBJECT_STATISTICS('VFPO', '*ALL')) F2
            ON F2.OBJLIB = F1.WHLNAM and F2.OBJNAME = F1.WHFNAM and F1.WHOTYP = F2.OBJTYPE
            ) F3
            LEFT JOIN TABLE(QSYS2.OBJECT_STATISTICS('VFPO', '*ALL')) F4
            on F3.WHLNAM = F4.OBJLIB
            where F4.OBJTYPE = '*PGM'
            order by LAST_USED_TIMESTAMP DESC
            )
            GROUP BY AGE_USED_GROUP, AGE_CREATED_GROUP
            ORDER BY AGE_USED_GROUP, AGE_CREATED_GROUP;


-- SELECT OBJLIB, OBJNAME, OBJTYPE, OBJDEFINER, CAST(OBJCREATED AS DATE) AS CREATED_DATE, OBJSIZE, OBJTEXT, CAST(LAST_USED_TIMESTAMP AS DATE) AS LAST_USED, DAYS_USED_COUNT
--   FROM TABLE(QSYS2.OBJECT_STATISTICS('VFPO', '*ALL')) A

--SELECT * FROM (
--SELECT * FROM QTEMP.PGMREF01 F1
--            LEFT JOIN TABLE(QSYS2.OBJECT_STATISTICS('VFPD', '*ALL')) F2
--            ON F2.OBJLIB = F1.WHLNAM and F2.OBJNAME = F1.WHFNAM and F1.WHOTYP = F2.OBJTYPE
--            ) F3;
