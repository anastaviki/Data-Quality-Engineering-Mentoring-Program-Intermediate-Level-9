''''








full_profiler_config_dict: dict = yaml.load(profiler_config)

rule_based_profiler: RuleBasedProfiler = RuleBasedProfiler(
    name=full_profiler_config_dict["name"],
    config_version=full_profiler_config_dict["config_version"],
    rules=full_profiler_config_dict["rules"],
    variables=full_profiler_config_dict["variables"],
    data_context=context,
)
# </snippet>



#asset = context.get_datasource("my_mssql_datasource").get_asset("Production.Product")


# <snippet name="tests/integration/docusaurus/expectations/advanced/multi_batch_rule_based_profiler_example.py run">
batch_request = BatchRequest(
    datasource_name="my_mssql_datasource",
    data_connector_name="default_inferred_data_connector_name",
    data_asset_name="Production.Product",  # this is the name of the table you want to retrieve
)

result: RuleBasedProfilerResult = rule_based_profiler.run(batch_request=batch_request)
print('res')
print(result)

expectation_configurations: List[
    ExpectationConfiguration
] = result.expectation_configurations

print(expectation_configurations)


expectation_suite_name = "HW_suite"

expectation_suite = context.add_or_update_expectation_suite(
    expectation_suite_name=expectation_suite_name
)
checkpoint_config = {
    "class_name": "SimpleCheckpoint",
    "validations": [
        {
            "batch_request": batch_request,
            "expectation_suite_name": expectation_suite_name,
        }
    ],
}

checkpoint = SimpleCheckpoint(
    name="Product_checkpoint",
    data_context=context,
    **checkpoint_config,
)
print ("checkpoint")
print (checkpoint)

checkpoint_result = checkpoint.run()

validation_results = checkpoint_result.list_validation_results()

print("checkpoint_result")

print(validation_results[0]["results"])
context.build_data_docs()



 #Update the weight of the first 10 products to be negative
with engine.begin() as conn:
    conn.execute("UPDATE Production.Product SET ReorderPoint = 3000 WHERE ProductID <= 10")
#()
result: RuleBasedProfilerResult = rule_based_profiler.run(batch_request=batch_request)
print(result)

expectation_configurations: List[
    ExpectationConfiguration
] = result.expectation_configurations

print(expectation_configurations)
checkpoint_result = checkpoint.run()
validation_results = checkpoint_result.list_validation_results()

print("checkpoint_result")

print(validation_results)
context.build_data_docs()

'''

# Here is a BatchRequest naming a table
batch_req = BatchRequest(
    datasource_name="my_mssql_datasource",
    data_connector_name="default_inferred_data_connector_name",
    data_asset_name="Production.Product",  # this is the name of the table you want to retrieve
)
#context.add_or_update_expectation_suite(expectation_suite_name="test_suite")
validator = context.get_validator(
    batch_request=batch_req, expectation_suite_name="test_suite"
)
print(validator.head(1000))
#asset = context.get_datasource("my_mssql_datasource").get_asset("Production.Product")

expectation_suite_name = "test_suite_1"

expectation_suite = context.add_or_update_expectation_suite(
    expectation_suite_name=expectation_suite_name
)

exclude_column_names = [
    "ProductID"
]
data_assistant_result = context.assistants.onboarding.run(
    batch_request=batch_req,
    exclude_column_names=exclude_column_names,
)

expectation_suite = data_assistant_result.get_expectation_suite(
    expectation_suite_name=expectation_suite_name
)

context.add_or_update_expectation_suite(expectation_suite=expectation_suite)


context.build_data_docs()


expectation_suite_name = "HW_suite"

expectation_suite = context.add_or_update_expectation_suite(
    expectation_suite_name=expectation_suite_name
)
checkpoint_config = {
    "class_name": "HW_Checkpoint",
    "validations": [
        {
            "batch_request": batch_req,
            "expectation_suite_name": expectation_suite_name,
        }
    ],
}

checkpoint = SimpleCheckpoint(
    name="Product_checkpoint",
    data_context=context,
    **checkpoint_config,
)
print ("checkpoint")
print (checkpoint)
context.save_checkpoint(checkpoint)

checkpoint_result = checkpoint.run()

validation_results = checkpoint_result.list_validation_results()


#assert checkpoint_result["success"] is True
print ("ss")
print(validation_results)
##print(checkpoint_result)

context.build_data_docs()