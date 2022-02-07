return function(_,condition: any, results: table)
    local case = results[condition] or results.default
    return type(case) == 'function' and case()
end