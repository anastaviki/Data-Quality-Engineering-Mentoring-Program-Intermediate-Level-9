
from typing import List
from great_expectations.checkpoint import SimpleCheckpoint
from great_expectations.core import ExpectationConfiguration, ExpectationSuite
import great_expectations as gx
from great_expectations.core.batch import BatchRequest
from great_expectations.core.yaml_handler import YAMLHandler
from great_expectations.rule_based_profiler.rule_based_profiler import RuleBasedProfiler
from great_expectations.rule_based_profiler import RuleBasedProfilerResult
from sqlalchemy import create_engine
yaml = YAMLHandler()


CONNECTION_STRING = "mssql+pyodbc://test_user:test_user@EPPLWARW01DC\\SQLEXPRESS/AdventureWorks2012?driver=ODBC Driver 17 for SQL Server&charset=utf&autocommit=true"
# Create a SQLAlchemy engine object to connect to the MSSQL database
engine = create_engine(CONNECTION_STRING)
context = gx.get_context()

# <snippet name="tests/integration/docusaurus/connecting_to_your_data/database/mssql_python_example.py datasource config">
datasource_config = {
    "name": "my_mssql_datasource",
    "class_name": "Datasource",
    "execution_engine": {
        "class_name": "SqlAlchemyExecutionEngine",
        "connection_string": "mssql+pyodbc://test_user:test_user@EPPLWARW01DC\\SQLEXPRESS/AdventureWorks2012?driver=ODBC Driver 17 for SQL Server&charset=utf&autocommit=true",
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
# </snippet>


# Please note this override is only to provide good UX for docs and tests.
# In normal usage you'd set your path directly in the yaml above.
datasource_config["execution_engine"]["connection_string"] = CONNECTION_STRING


context.test_yaml_config(yaml.dump(datasource_config))

context.add_datasource(**datasource_config)

context.add_or_update_expectation_suite("my_expectation_suite")
profiler_config = r"""
# <snippet name="tests/integration/docusaurus/expectations/advanced/multi_batch_rule_based_profiler_example.py full profiler_config">
# <snippet name="tests/integration/docusaurus/expectations/advanced/multi_batch_rule_based_profiler_example.py full row_count_rule">
# This profiler is meant to be used on the NYC taxi data (yellow_tripdata_sample_<YEAR>-<MONTH>.csv)
# located in tests/test_sets/taxi_yellow_tripdata_samples/
# <snippet name="tests/integration/docusaurus/expectations/advanced/multi_batch_rule_based_profiler_example.py name and config_version">
name: My Profiler
config_version: 1.0
# </snippet>
# <snippet name="tests/integration/docusaurus/expectations/advanced/multi_batch_rule_based_profiler_example.py variables and rule name">
variables:
  false_positive_rate: 0.01
  mostly: 1.0
rules:
  row_count_rule:
# </snippet>
# <snippet name="tests/integration/docusaurus/expectations/advanced/multi_batch_rule_based_profiler_example.py row_count_rule domain_builder">
    domain_builder:
        class_name: TableDomainBuilder
# </snippet>
# <snippet name="tests/integration/docusaurus/expectations/advanced/multi_batch_rule_based_profiler_example.py row_count_rule parameter_builders">
    parameter_builders:
      - name: row_count_range
        class_name: NumericMetricRangeMultiBatchParameterBuilder
        metric_name: table.row_count
        metric_domain_kwargs: $domain.domain_kwargs
        false_positive_rate: $variables.false_positive_rate
        truncate_values:
          lower_bound: 0
        round_decimals: 0
# </snippet>
# <snippet name="tests/integration/docusaurus/expectations/advanced/multi_batch_rule_based_profiler_example.py row_count_rule expectation_configuration_builders">
    expectation_configuration_builders:
      - expectation_type: expect_table_row_count_to_be_between
        class_name: DefaultExpectationConfigurationBuilder
        module_name: great_expectations.rule_based_profiler.expectation_configuration_builder
        min_value: $parameter.row_count_range.value[0]
        max_value: $parameter.row_count_range.value[1]
        mostly: $variables.mostly
        meta:
          profiler_details: $parameter.row_count_range.details
# </snippet>
# </snippet>
# <snippet name="tests/integration/docusaurus/expectations/advanced/multi_batch_rule_based_profiler_example.py column_ranges_rule domain_builder">
  column_ranges_rule:
    domain_builder:
      class_name: ColumnDomainBuilder
      include_semantic_types:
        - numeric
# </snippet>
# <snippet name="tests/integration/docusaurus/expectations/advanced/multi_batch_rule_based_profiler_example.py column_ranges_rule parameter_builders">
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
# </snippet>
# <snippet name="tests/integration/docusaurus/expectations/advanced/multi_batch_rule_based_profiler_example.py column_ranges_rule expectation_configuration_builders">
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
# </snippet>
# </snippet>
"""




full_profiler_config_dict: dict = yaml.load(profiler_config)

rule_based_profiler: RuleBasedProfiler = RuleBasedProfiler(
    name=full_profiler_config_dict["name"],
    config_version=full_profiler_config_dict["config_version"],
    rules=full_profiler_config_dict["rules"],
    variables=full_profiler_config_dict["variables"],
    data_context=context,
)

full_profiler_config_dict: dict = yaml.load(profiler_config)

rule_based_profiler: RuleBasedProfiler = RuleBasedProfiler(
    name=full_profiler_config_dict["name"],
    config_version=full_profiler_config_dict["config_version"],
    rules=full_profiler_config_dict["rules"],
    variables=full_profiler_config_dict["variables"],
    data_context=context,
)

batch_request = BatchRequest(
    datasource_name="my_mssql_datasource",
    data_connector_name="default_inferred_data_connector_name",
    data_asset_name="Production.Product",  # this is the name of the table you want to retrieve
)

profiler_results: RuleBasedProfilerResult = rule_based_profiler.run(batch_request=batch_request)
print('res')
print(profiler_results)

expectation_configurations: List[
    ExpectationConfiguration
] = profiler_results.expectation_configurations
print("profiler_results")
print(profiler_results)


# Create an expectation suite with the configurations
expectation_suite = ExpectationSuite(expectation_configurations)
for expectation_configuration in profiler_results.expectation_configurations:
    expectation_suite.add_expectation(expectation_configuration)


# Save the expectation suite to the data context
context.save_expectation_suite(expectation_suite, "my_expectation_suite")

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

checkpoint_result = context.run_checkpoint(checkpoint_name="test_checkpoint")

validation_results = checkpoint_result.list_validation_results()

print("checkpoint_result")

print(validation_results[0]["results"])
context.build_data_docs()