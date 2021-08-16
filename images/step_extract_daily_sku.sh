#!/bin/ksh
#
# Description: extracts step daily published sku list from step for Omniture
# 
#
if [ "$1" = "-x" ];then
        set -x
        shift
fi

LOCATION=$ACE_OUTBOUND_DAILY_SKU
OUTPUT_FILE=daily_published_product_`date +%Y%m%d`

USER_PASS_SID=`FsAutosysUserPassSid STP autosys`||exit 99 # autosys/{DB_STPV_AUTOSYS}@STPV

sqlplus -s /nolog <<END-OF-SQL > /dev/null
connect $USER_PASS_SID

set term off
set feedback off
set verify off
set pages 0
set heading off
set colsep ''
set trimspool on
set head off
set linesize 30000

WHENEVER SQLERROR EXIT FAILURE

spool $LOCATION/$OUTPUT_FILE.tab

set define off

EXEC stepview.pimviewapipck.setviewcontext('Canadian English', 'Main');

SELECT
  '##' || ' SC	' || 'SiteCatalyst SAINT Import File	' || 'v:2.1'
FROM dual;

SELECT
  '##' || ' SC	' || '''##'|| ' SC'' indicates a SiteCatalyst pre-process header. Please do not remove these lines.'
FROM dual;

SELECT
  '##' || ' SC	' || 'D:2017-05-26 14:18:37	' || 'A:400008536:51'
FROM dual;  

SELECT
  'Key' ||'	'||
  'Description' ||'	'||
  'Department' ||'	'||
  'Class' ||'	'||
  'Brand' ||'	'||
  'RMS Department' ||'	'||
  'RMS Class' ||'	'||
  'RMS Sub-Class' ||'	'||
  'CSG' ||'	'||
  'ChainSupp' ||'	'||
  'STEP - Group' ||'	'||
  'STEP - Department' ||'	'||
  'STEP - Class' ||'	'||
  'STEP - Sub-Class' ||'	'||
  'Sub-Class'
FROM dual;

    SELECT
       sku || '	' ||
       sku || ' | ' || title || '	' ||
       ' ' || '	' ||
       ' ' || '	' ||
       brand || '	' ||
       rms_dept || '	' ||
       rms_class || '	' ||
       rms_subclass || '	' ||
       csg || '	' ||
       ' ' || '	' ||
       ' ' || '	' ||
       ' ' || '	' ||
       ' ' || '	' ||
       ' ' || '	' ||
       ' '
    FROM (
     SELECT
        REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(sku, '''', ''), '"', ''), ',', ''), '&amp;', '&'), 'Ã‰', 'É'), '&quot;', ''), 'Ã¼', 'ü'), 'â€¯', ' '), '&frac12;', ' 1/2') sku,
        REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(title, '''', ''), '"', ''), ',', ''), '&amp;', '&'), 'Ã‰', 'É'), '&quot;', ''), 'Ã¼', 'ü'), 'â€¯', ' '), '&frac12;', ' 1/2') title,
        REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(brand, '''', ''), '"', ''), ',', ''), '&amp;', '&'), 'Ã‰', 'É'), '&quot;', ''), 'Ã¼', 'ü'), 'â€¯', ' '), '&frac12;', ' 1/2') brand,
        REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(csg, '''', ''), '"', ''), ',', ''), '&amp;', '&'), 'Ã‰', 'É'), '&quot;', ''), 'Ã¼', 'ü'), 'â€¯', ' '), '&frac12;', ' 1/2') csg,
        REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(rms_dept, '''', ''), '"', ''), ',', ''), '&amp;', '&'), 'Ã‰', 'É'), '&quot;', ''), 'Ã¼', 'ü'), 'â€¯', ' '), '&frac12;', ' 1/2') rms_dept,
        REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(rms_class, '''', ''), '"', ''), ',', ''), '&amp;', '&'), 'Ã‰', 'É'), '&quot;', ''), 'Ã¼', 'ü'), 'â€¯', ' '), '&frac12;', ' 1/2') rms_class,
        REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(rms_subclass, '''', ''), '"', ''), ',', ''), '&amp;', '&'), 'Ã‰', 'É'), '&quot;', ''), 'Ã¼', 'ü'), 'â€¯', ' '), '&frac12;', ' 1/2') rms_subclass
     FROM (
        SELECT
             CASE hier.group_context_name
                  WHEN 'Music & Movies' then 'M' || stepview.pimviewapipck.getcontextvalue4node(p.id, (SELECT id FROM stepview.attribute_v WHERE name = 'SKU'))
                  ELSE stepview.pimviewapipck.getcontextvalue4node(p.id, (SELECT id FROM stepview.attribute_v WHERE name = 'SKU'))
             END sku,
             stepview.pimviewapipck.getcontextvalue4node(p.id, (SELECT id FROM stepview.attribute_v WHERE name = 'Title_BB')) title,
             stepview.pimviewapipck.getcontextvalue4node(p.id, (SELECT id  FROM stepview.attribute_v WHERE name = 'Brand_Name')) brand,
             hier.group_context_name csg,
             hier.dept_context_name rms_dept,
             hier.class_context_name rms_class,
             hier.subclass_context_name rms_subclass
        FROM stepview.product_v p
        INNER JOIN stepview.product_status_change psc
            on p.id = psc.node_id
        INNER JOIN stepview.productclassificationlink_v  plv
            on plv.productid = p.id
        INNER JOIN stepview.rms_hierarchy  hier
            on hier.subclass_id = plv.classificationid
        WHERE TRUNC (psc.status_ts) = TRUNC(sysdate-1)
         AND psc.status = 'Online'
         AND p.subtypeid IN (SELECT id FROM stepview.pimsubtype_all WHERE name IN ('ESKU', 'RSKU', 'PRP_PSP'))
         AND stepview.pimviewapipck.getname(plv.linktypeid) = 'Ref_RMS'
         )
    );

spool off
END-OF-SQL
echo "fin" > $LOCATION/$OUTPUT_FILE.fin

