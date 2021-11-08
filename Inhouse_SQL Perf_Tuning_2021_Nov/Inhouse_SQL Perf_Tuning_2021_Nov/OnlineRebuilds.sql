USE TPC_E
GO

-- Start a resumable Online Index Operation...
ALTER INDEX PK__E_TRADE__83BB1FB25FB337D6 ON E_TRADE REBUILD WITH
(
	ONLINE = ON,
	RESUMABLE = ON
)
GO

ALTER INDEX CompanyName ON Customers REBUILD WITH
(
	ONLINE = ON,
	RESUMABLE = ON
)
GO

-- As soon as the Online Index Operation is started, we can see it in sys.index_resumable_operations
SELECT * FROM sys.index_resumable_operations
GO

-- Stop the Online Index Operation by cancelling the query...
-- ...

-- The Online Index Operation is now in the PAUSED state
SELECT * FROM sys.index_resumable_operations
GO

-- Resume the paused Online Index Operation
ALTER INDEX PK__E_TRADE__83BB1FB25FB337D6 ON E_TRADE REBUILD WITH
(
	ONLINE = ON,
	RESUMABLE = ON
)
GO

-- Pause the Online Index Operation manually.
-- The session gets disconnected...
ALTER INDEX PK__E_TRADE__83BB1FB25FB337D6 ON E_TRADE PAUSE
GO

-- Abort the Online Index Operation.
-- The session gets again disconnected...
ALTER INDEX PK__E_TRADE__83BB1FB25FB337D6 ON E_TRADE ABORT
GO

-- There is no entry anymore...
SELECT * FROM sys.index_resumable_operations
GO

-- The Online Index Operation will be paused after 1 Minute...
ALTER INDEX PK__E_TRADE__83BB1FB25FB337D6 ON E_TRADE REBUILD WITH
(
	ONLINE = ON,
	RESUMABLE = ON,
	MAX_DURATION = 1 MINUTES
)
GO

-- The Online Index Operation is now again in the PAUSED state
SELECT * FROM sys.index_resumable_operations
GO

-- Resume the paused Online Index Operation
ALTER INDEX PK__E_TRADE__83BB1FB25FB337D6 ON E_TRADE RESUME
GO