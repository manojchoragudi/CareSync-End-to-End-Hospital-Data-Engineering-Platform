/* =====================================================================
   CareSync Health Network — Control/Metadata Framework
   Target: Azure SQL Database
   Drops the 3 control tables in FK-safe order (child tables first).
   Run this before re-running create_control_tables.sql.
   ===================================================================== */

IF OBJECT_ID('ctrl.audit_log', 'U') IS NOT NULL
    DROP TABLE ctrl.audit_log;
GO

IF OBJECT_ID('ctrl.watermark', 'U') IS NOT NULL
    DROP TABLE ctrl.watermark;
GO

IF OBJECT_ID('ctrl.table_config', 'U') IS NOT NULL
    DROP TABLE ctrl.table_config;
GO
