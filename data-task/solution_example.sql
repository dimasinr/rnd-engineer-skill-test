CREATE TABLE experiments (
    experiment_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(100) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    tags JSONB,
    CONSTRAINT uq_experiment_name UNIQUE (name)
);

CREATE TABLE runs (
    run_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    experiment_id INTEGER REFERENCES experiments(experiment_id),
    start_time TIMESTAMP WITH TIME ZONE NOT NULL,
    end_time TIMESTAMP WITH TIME ZONE,
    status VARCHAR(50) CHECK (status IN ('RUNNING', 'COMPLETED', 'FAILED', 'STOPPED')),
    created_by VARCHAR(100) NOT NULL,
    environment JSONB NOT NULL,
    git_commit VARCHAR(100),
    notes TEXT,
    parent_run_id UUID REFERENCES runs(run_id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE parameters (
    parameter_id SERIAL PRIMARY KEY,
    run_id UUID REFERENCES runs(run_id) ON DELETE CASCADE,
    param_name VARCHAR(100) NOT NULL,
    param_value TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(run_id, param_name)
);

CREATE TABLE metrics (
    metric_id SERIAL PRIMARY KEY,
    run_id UUID REFERENCES runs(run_id) ON DELETE CASCADE,
    metric_name VARCHAR(100) NOT NULL,
    metric_value DOUBLE PRECISION NOT NULL,
    step INTEGER,
    is_objective BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE artifacts (
    artifact_id SERIAL PRIMARY KEY,
    run_id UUID REFERENCES runs(run_id) ON DELETE CASCADE,
    artifact_name VARCHAR(255) NOT NULL,
    artifact_type VARCHAR(50) NOT NULL,
    uri TEXT NOT NULL,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE tags (
    tag_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    color VARCHAR(20)
);

CREATE TABLE run_tags (
    run_id UUID REFERENCES runs(run_id) ON DELETE CASCADE,
    tag_id INTEGER REFERENCES tags(tag_id) ON DELETE CASCADE,
    PRIMARY KEY (run_id, tag_id)
);

CREATE INDEX idx_runs_experiment_id ON runs(experiment_id);
CREATE INDEX idx_metrics_run_id ON metrics(run_id);
CREATE INDEX idx_parameters_run_id ON parameters(run_id);
CREATE INDEX idx_artifacts_run_id ON artifacts(run_id);
CREATE INDEX idx_runs_created_at ON runs(created_at);
CREATE INDEX idx_metrics_created_at ON metrics(created_at);