-- Cash Service Database Initialization
-- xledger_cash

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Set default schema
SET search_path TO public;

-- Database is ready
-- Schema migrations will be managed by Flyway in cash-service
