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
    DECLARE @Msg NVARCHAR(MAX);
    SET @Msg = 'RowCount of ' + @FullName + ' expected [ ' + CAST(@Expected AS NVARCHAR(MAX)) + ' ] but was [ ' + CAST(@rowCount AS NVARCHAR(MAX)) + ' ]' + CHAR(13) + CHAR(10);
    EXEC tSQLt.Fail @Message,@Msg;
  END

END;
GO
---Build-
GO
