function GEN_AUDIT_TRIGGER_TEXT_new(X_TABLE_NAME VARCHAR2,
                                      X_OWNER      VARCHAR2) RETURN CLOB IS
    TEXT           CLOB := '';
    V_TABLE_NAME   VARCHAR2(30) := upper(X_TABLE_NAME);
    V_TRIGGER_NAME VARCHAR2(30) := 'T_CF_' ||
                                   SUBSTR(V_TABLE_NAME, 1, 30 - 5);
    V_OWNER        VARCHAR2(30) := upper(X_OWNER);
  
    CURSOR C_PK IS
      SELECT cols.table_name,
             cols.column_name,
             cols.position,
             cons.status,
             cons.owner,
             CASE
               WHEN count(*) over() > 1 THEN
                1
               ELSE
                0
             END AS IS_COMPOSITE_PK,
             c.DATA_TYPE
        FROM all_constraints cons, all_cons_columns cols, all_tab_cols c
       WHERE cols.table_name = V_TABLE_NAME
         AND cons.constraint_type = 'P'
         AND cons.constraint_name = cols.constraint_name
         AND cons.owner = cols.owner
         and cons.status = 'ENABLED'
         and c.TABLE_NAME = cons.TABLE_NAME
         and c.COLUMN_NAME = cols.COLUMN_NAME
         and c.Owner = cols.OWNER;
    R_PK C_PK%ROWTYPE;
  
    CURSOR C_COLS IS
      SELECT 'appl_admin.audit_pkg.check_val_' || case
               when C.DATA_TYPE = 'VARCHAR2' then
                'c'
               when C.DATA_TYPE = 'DATE' then
                'd'
               else
                'n'
             end || '(V_TABLE_NAME, ''' || C.COLUMN_NAME || ''', :new.' ||
             C.COLUMN_NAME || ', :old.' || C.COLUMN_NAME ||
             ', V_OPERATION, V_PK_VALUE);' AS LINE,
             C.COLUMN_NAME
        FROM ALL_TAB_COLS C
       WHERE C.TABLE_NAME = V_TABLE_NAME
         AND C.OWNER = V_OWNER
         AND C.DATA_TYPE in ('VARCHAR2', 'DATE', 'NUMBER')
         AND C.virtual_column = 'NO'
       ORDER BY C.COLUMN_ID;
       --appl_admin.gda_seq.nextval
       --jn_operation, jn_datetime, jn_user, jn_osuser, jn_machine, jn_program, jn_module, record_id, 
       --table_name, column_name, old_value_vc, new_value_vc, old_value_n, new_value_n, old_value_d, new_value_d
       cursor c_cols2 is 
       --select c1.COLUMN_NAME, 'select V_OPERATION as jn_operation, sysdate as jn_datetime, user as jn_user, r_kto.osuser as jn_osuser, r_kto.machine as jn_machine, r_kto.program as jn_program, r_kto.module as jn_module, V_PK_VALUE as record_id, ' || '''' || c1.table_name || ''' as table_name, ' || '''' || c1.COLUMN_NAME || ''' as column_name, ' 
       select c1.data_type, c1.COLUMN_NAME, 'select ''' || c1.COLUMN_NAME || ''' as column_name, ' 
       || case when c1.DATA_TYPE = 'VARCHAR2' then ':old.'||c1.COLUMN_NAME else 'null' end || ' as old_value_vc, ' ||
case when c1.DATA_TYPE = 'VARCHAR2' then ':new.'||c1.COLUMN_NAME else 'null' end || ' as new_value_vc, ' ||
  
case when c1.DATA_TYPE = 'NUMBER' then ':old.'||c1.COLUMN_NAME else 'null' end || ' as old_value_n, ' ||
  case when c1.DATA_TYPE = 'NUMBER' then ':new.'||c1.COLUMN_NAME else 'null' end || ' as new_value_n, ' ||
    
  
  case when c1.DATA_TYPE = 'DATE' then ':old.'||c1.COLUMN_NAME else 'null' end || ' as old_value_d, ' ||
    case when c1.DATA_TYPE = 'DATE' then ':new.'||c1.COLUMN_NAME else 'null' end || ' as new_value_d '
      --|| ' from  v$session vs WHERE vs.audsid = userenv(''sessionid'') '
      || ', ''' || c1.DATA_TYPE || ''' as data_type from dual where ' ||
      ' :new.'||c1.COLUMN_NAME||' <> :old.'||c1.COLUMN_NAME||' or (:new.'||c1.COLUMN_NAME||' is null and :old.'||c1.COLUMN_NAME||' is not NULL) or (:new.'||c1.COLUMN_NAME||' is not null and :old.'||c1.COLUMN_NAME||' is NULL) ' 
  /*    case c1.DATA_TYPE 
        when 'VARCHAR2' then ' :new.'||c1.COLUMN_NAME||' <> x_old or (x_new is null and x_old is not NULL) or (x_new is not null and x_old is NULL) ' 
        when 'NUMBER' then ' x_new <> x_old or (x_new is null and x_old is not NULL) or (x_new is not null and x_old is NULL) ' 
        when 'DATE' then ' x_new <> x_old or (x_new is null and x_old is not NULL) or (x_new is not null and x_old is NULL) ' 
          else ' 1=1 ' end*/
        
       as line
      
  from all_tab_cols c1
 where C1.TABLE_NAME = V_TABLE_NAME
         AND C1.OWNER = V_OWNER
         AND C1.DATA_TYPE in ('VARCHAR2', 'DATE', 'NUMBER')
         AND C1.virtual_column = 'NO'
   and c1.COLUMN_NAME not in ('DATE_CREATED', 'DATE_MODIFIED', 'CREATED_BY', 'MODIFIED_BY')
 order by c1.COLUMN_ID;
  
  BEGIN
  
    OPEN C_PK;
    FETCH C_PK
      INTO R_PK;
    IF C_PK%FOUND THEN
      CLOSE C_PK;
    ELSE
      CLOSE C_PK;
      raise_application_error(-20000,
                              'Tables without PK are not supported.');
    END IF;
  
    if R_PK.IS_COMPOSITE_PK = 1 THEN
      raise_application_error(-20000, 'Composite PK is not supported.');
    end if;
  
    if R_PK.DATA_TYPE <> 'NUMBER' THEN
      raise_application_error(-20000,
                              'Only NUMBER data type columns are supported as PK.');
    end if;
  
    TEXT := TEXT || 'CREATE OR REPLACE TRIGGER ' || V_OWNER || '.' ||
            V_TRIGGER_NAME || CHR(10);
    TEXT := TEXT || 'AFTER UPDATE /*OR INSERT OR DELETE*/ ON ' || V_OWNER || '.' ||
            V_TABLE_NAME || CHR(10);
    TEXT := TEXT || 'FOR EACH ROW' || CHR(10);
  
    TEXT := TEXT || 'DECLARE' || CHR(10);
    TEXT := TEXT || '  V_TABLE_NAME VARCHAR2(30);' || CHR(10);
    TEXT := TEXT || '  V_PK_VALUE VARCHAR2(100);' || CHR(10);
    TEXT := TEXT || '  V_OPERATION VARCHAR2(3);' || CHR(10);
    
    TEXT := TEXT || '  cursor c_kto is SELECT vs.USERNAME, vs.OSUSER, vs.MACHINE, vs.PROGRAM, vs.MODULE, vs.ACTION FROM v$session vs WHERE vs.audsid = userenv(''sessionid'');' || CHR(10);
    TEXT := TEXT || '  r_kto c_kto%rowtype;' || chr(10);
    TEXT := TEXT || 'BEGIN' || CHR(10);
    
    TEXT := TEXT || '  open c_kto; fetch c_kto into r_kto; close c_kto;' || CHR(10);
  
    TEXT := TEXT || '  V_TABLE_NAME := ''' || upper(X_TABLE_NAME) || ''';' || CHR(10);
  
    TEXT := TEXT || '  V_PK_VALUE := ' || 'NVL(:new.' || R_PK.COLUMN_NAME ||
            ', :old.' || R_PK.COLUMN_NAME || ')' || ';' || CHR(10);
  
    TEXT := TEXT || '  V_OPERATION := ' ||
            'CASE WHEN INSERTING THEN ''I'' WHEN UPDATING THEN ''U'' ELSE ''D'' END' || ';' ||
            CHR(10);

    text := TEXT || CHR(10) || 'insert into appl_admin.global_dml_audit_fast (id, jn_operation, jn_datetime, jn_user, jn_osuser, jn_machine, jn_program, jn_module, record_id, table_name, column_name, old_value_vc, new_value_vc, old_value_n, new_value_n, old_value_d, new_value_d, data_type)';
    text := TEXT || CHR(10) || 'select appl_admin.gda_seq.nextval, V_OPERATION, sysdate, user, r_kto.OSUSER, r_kto.MACHINE, r_kto.PROGRAM, r_kto.module, V_PK_VALUE, v_table_name, column_name, old_value_vc, new_value_vc, old_value_n, new_value_n, old_value_d, new_value_d, data_type from (';
  
    FOR R in c_cols2 LOOP

      if R.COLUMN_NAME = R_PK.COLUMN_NAME then
        --TEXT := TEXT || CHR(10) || '--  ' || R.LINE;
        null;
      elsif R.COLUMN_NAME in ('DATE_CREATED', 'DATE_MODIFIED', 'MODIFIED_BY', 'CREATED_BY') then
        --TEXT := TEXT || CHR(10) || '--  ' || R.LINE;
        null;
      ELSE
        TEXT := TEXT || CHR(10) || '  ' || R.LINE || CHR(10) || ' union all ';
        
      end if;
    END LOOP;
  
    text := substr(text, 1, length(text)-11) || ');' || chr(10);
  
    TEXT := TEXT || CHR(10) || CHR(10) || 'END;' || CHR(10);
  
    RETURN TEXT;
  
  END;
