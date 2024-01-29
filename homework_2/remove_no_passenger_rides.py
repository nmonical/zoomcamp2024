if 'transformer' not in globals():
    from mage_ai.data_preparation.decorators import transformer
if 'test' not in globals():
    from mage_ai.data_preparation.decorators import test


import pandas as pd

@transformer
def transform(data, *args, **kwargs):
    """
    Template code for a transformer block.

    Add more parameters to this function if this block has multiple parent blocks.
    There should be one parameter for each output variable from each parent block.

    Args:
        data: The output from the upstream parent block
        args: The output from any additional upstream blocks (if applicable)

    Returns:
        Anything (e.g. data frame, dictionary, array, int, str, etc.)
    """
 
    # Specify your transformation logic here
    def change_case(str):
     
        return ''.join(['_'+i.lower() if i.isupper() 
               else i for i in str]).lstrip('_')

    output = data[(data['passenger_count']>0) & (data['trip_distance']>0)]
    output.columns = (output.columns
                .str.replace('(?<=[a-z])(?=[A-Z])', '_', regex=True)
                .str.lower()
             )
    output['lpep_pickup_date'] = output['lpep_pickup_datetime'].dt.date


    return output


@test
def test_output(output, *args) -> None:
    """
    Template code for testing the output of the block.
"""
    vendors = list(output['vendor_id'].unique())
    assert output['passenger_count'].isin([0]).sum()==0, 'There are rides without passengers'
    assert output['vendor_id'].isin(vendors).sum()!=0, 'Vendor ID is not in range'
    assert output['trip_distance'].isin([0]).sum()==0, 'There are zero distance rides'
