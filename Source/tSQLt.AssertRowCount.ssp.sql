IF OBJECT_ID('tSQLt.AssertRowCount') IS NOT NULL DROP PROCEDURE tSQLt.AssertRowCount;
GO
---Build+
GO
CREATE PROCEDURE tSQLt.AssertRowCount
    @Expected BIGINT = 0,
    @TableName NVARCHAR(MAX),
    @Message NVARCHAR(MAX) = ''
AS
BEGIN
      
  EXEC tSQLt.AssertObjectExists @TableName;

  DECLARE @FullName NVARCHAR(MAX);
  IF(OBJECT_ID(@TableName) IS NULL AND OBJECT_ID('tempdb..'+@TableName) IS NOT NULL)
  BEGIN
    SET @FullName = CASE WHEN LEFT(@TableName,1) = '[' THEN @TableName ELSE QUOTENAME(@TableName)END;
  END;
  ELSE
  BEGIN
    SET @FullName = tSQLt.Private_GetQuotedFullName(OBJECT_ID(@TableName));
  END;

  DECLARE @cmd NVARCHAR(MAX);
  DECLARE @rowCount BIGINT;
  SET @cmd = 'SELECT @rowCount = COUNT_BIG(*) FROM '+@FullName+';'
  EXEC sp_executesql @cmd,N'@rowCount BIGINT OUTPUT', @rowCount OUTPUT;
  
  IF(@rowCount <> @Expected)
  BEGIN
    DECLARE @TableToText NVARCHAR(MAX);
    EXEC tSQLt.TableToText @TableName = @FullName,@txt = @TableToText OUTPUT;
    DECLARE @Msg NVARCHAR(MAX);
    SET @Msg = 'Rowcount of ' + @FullName + ' expected :' + @Expected + ' but was ' + @rowCount + CHAR(13) + CHAR(10)+ @TableToText;
    EXEC tSQLt.Fail @Message,@Msg;
  END

END;
GO
---Build-
GO
