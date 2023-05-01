# import all necessary libraries
from typing import List
from great_expectations.core import ExpectationConfiguration, ExpectationSuite
import great_expectations as gx
from great_expectations.core.batch import BatchRequest
from great_expectations.core.yaml_handler import YAMLHandler
from great_expectations.rule_based_profiler.rule_based_profiler import RuleBasedProfiler
from great_expectations.rule_based_profiler import RuleBasedProfilerResult
from sqlalchemy import create_engine
yaml = YAMLHandler()

CONNECTION_STRING = "mssql+pyodbc://test_user:test_user@EPPLWARW01DC\\SQLEXPRESS/" \
                    "AdventureWorks2012?driver=ODBC Driver 17 for SQL Server&charset=utf&autocommit=true"
# Create a SQLAlchemy engine object to connect to the MSSQL database
engine = create_engine(CONNECTION_STRING)
context = gx.get_context()
# create datasource config
datasource_config = {
    "name": "my_mssql_datasource",
    "class_name": "Datasource",
    "execution_engine": {
        "class_name": "SqlAlchemyExecutionEngine",
        "connection_string": "mssql+pyodbc://test_user:test_user@EPPLWARW01DC\\SQLEXPRESS/"
                             "AdventureWorks2012?driver=ODBC Driver 17 for SQL Server&charset=utf&autocommit=true",
    },
    "data_connectors": {
        "default_runtime_data_connector_name": {
            "class_name": "RuntimeDataConnector",
            "batch_identifiers": ["default_identifier_name"],
        },
        "default_inferred_data_connector_name": {
            "class_name": "InferredAssetSqlDataConnector",
            "include_schema_name": True,


        },
    },
}
# add datasource config to context
datasource_config["execution_engine"]["connection_string"] = CONNECTION_STRING
context.test_yaml_config(yaml.dump(datasource_config))
context.add_datasource(**datasource_config)

# add or update expectation suite
context.add_or_update_expectation_suite("my_expectation_suite")
# create config to profiler
profiler_config = r"""
name: My Profiler
config_version: 1.0
variables:
  false_positive_rate: 0.01
  mostly: 1.0
rules:
  row_count_rule:
    domain_builder:
        class_name: TableDomainBuilder
    parameter_builders:
      - name: row_count_range
        class_name: NumericMetricRangeMultiBatchParameterBuilder
        metric_name: table.row_count
        metric_domain_kwargs: $domain.domain_kwargs
        false_positive_rate: $variables.false_positive_rate
        truncate_values:
          lower_bound: 0
        round_decimals: 0
    expectation_configuration_builders:
      - expectation_type: expect_table_row_count_to_be_between
        class_name: DefaultExpectationConfigurationBuilder
        module_name: great_expectations.rule_based_profiler.expectation_configuration_builder
        min_value: $parameter.row_count_range.value[0]
        max_value: $parameter.row_count_range.value[1]
        mostly: $variables.mostly
        meta:
          profiler_details: $parameter.row_count_range.details
  column_ranges_rule:
    domain_builder:
      class_name: ColumnDomainBuilder
      include_semantic_types:
        - numeric
    parameter_builders:
      - name: min_range
        class_name: NumericMetricRangeMultiBatchParameterBuilder
        metric_name: column.min
        metric_domain_kwargs: $domain.domain_kwargs
        false_positive_rate: $variables.false_positive_rate
        round_decimals: 2
      - name: max_range
        class_name: NumericMetricRangeMultiBatchParameterBuilder
        metric_name: column.max
        metric_domain_kwargs: $domain.domain_kwargs
        false_positive_rate: $variables.false_positive_rate
        round_decimals: 2
    expectation_configuration_builders:
      - expectation_type: expect_column_min_to_be_between
        class_name: DefaultExpectationConfigurationBuilder
        module_name: great_expectations.rule_based_profiler.expectation_configuration_builder
        column: $domain.domain_kwargs.column
        min_value: $parameter.min_range.value[0]
        max_value: $parameter.min_range.value[1]
        mostly: $variables.mostly
        meta:
          profiler_details: $parameter.min_range.details
      - expectation_type: expect_column_max_to_be_between
        class_name: DefaultExpectationConfigurationBuilder
        module_name: great_expectations.rule_based_profiler.expectation_configuration_builder
        column: $domain.domain_kwargs.column
        min_value: $parameter.max_range.value[0]
        max_value: $parameter.max_range.value[1]
        mostly: $variables.mostly
        meta:
          profiler_details: $parameter.max_range.details
"""

full_profiler_config_dict: dict = yaml.load(profiler_config)

rule_based_profiler: RuleBasedProfiler = RuleBasedProfiler(
    name=full_profiler_config_dict["name"],
    config_version=full_profiler_config_dict["config_version"],
    rules=full_profiler_config_dict["rules"],
    variables=full_profiler_config_dict["variables"],
    data_context=context,
)

# create batch Request for asset Production.Product
batch_request = BatchRequest(
    datasource_name="my_mssql_datasource",
    data_connector_name="default_inferred_data_connector_name",
    data_asset_name="Production.Product",  # this is the name of the table you want to retrieve
)

# run profiler
profiler_results: RuleBasedProfilerResult = rule_based_profiler.run(batch_request=batch_request)

expectation_configurations: List[
    ExpectationConfiguration
] = profiler_results.expectation_configurations

# Create an expectation suite with the configurations from profiler
expectation_suite = ExpectationSuite("my_expectation_suite")
for expectation_configuration in profiler_results.expectation_configurations:
    expectation_suite.add_expectation(expectation_configuration)

# Save the expectation suite to the data context
context.save_expectation_suite(expectation_suite, "my_expectation_suite")
# I tried to use another function not save_expectation_suite, but it is not work as expected
# Add a Checkpoint
checkpoint_yaml = """
name: test_checkpoint
config_version: 1
class_name: Checkpoint
run_name_template: "%Y-%M-foo-bar-template"
validations:
  - batch_request:
      datasource_name: my_mssql_datasource
      data_connector_name: default_inferred_data_connector_name
      data_asset_name: Production.Product
    expectation_suite_name: my_expectation_suite
    action_list:
      - name: <ACTION NAME FOR STORING VALIDATION RESULTS>
        action:
          class_name: StoreValidationResultAction
      - name: <ACTION NAME FOR STORING EVALUATION PARAMETERS>
        action:
          class_name: StoreEvaluationParametersAction
      - name: <ACTION NAME FOR UPDATING DATA DOCS>
        action:
          class_name: UpdateDataDocsAction
"""
context.add_or_update_checkpoint(**yaml.load(checkpoint_yaml))
assert context.list_checkpoints() == ["test_checkpoint"]

# run checkpoint
checkpoint_result = context.run_checkpoint(checkpoint_name="test_checkpoint")
validation_results = checkpoint_result.list_validation_results()

# add info to data docks
context.build_data_docs()

# Update the ReorderPoint of the ProductID <= 10 to be 7000
with engine.begin() as conn:
    conn.execute("UPDATE Production.Product SET ReorderPoint = 7000 WHERE ProductID <= 10")
result: RuleBasedProfilerResult = rule_based_profiler.run(batch_request=batch_request)

# run checkpoint again
checkpoint_result = context.run_checkpoint(checkpoint_name="test_checkpoint")

# add info to data docks
context.build_data_docs()
