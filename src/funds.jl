
module Funds

    using Dates
    import ..YearMonths
    import ..Downloads
    import ..CSV
    import ..ZipFile
    import ..HTTP

    struct FundData
        fund_type::Union{String, Nothing}
        cnpj::String
        date::Date
        total_value::Float64
        quota_value::Float64
        net_worth::Float64
        deposits::Float64
        withdraws::Float64
        number_quota_holders::Int64
    end

    function get_month_quotes(ym::YearMonths.YearMonth)::Vector{FundData}
        @assert ym >= YearMonths.YearMonth(2017, 1)

        data = _get_data(ym)

        out = Vector{FundData}()

        for row in data

            fund_type = get(row, :TP_FUNDO, nothing)
            cnpj = row.CNPJ_FUNDO
            date = row.DT_COMPTC
            total_value = row.VL_TOTAL
            quota_value = row.VL_QUOTA
            net_worth = row.VL_PATRIM_LIQ
            deposits = row.CAPTC_DIA
            withdraws = row.RESG_DIA
            number_quota_holders = row.NR_COTST

            d = FundData(
                fund_type, cnpj, date,
                total_value, quota_value, net_worth,
                deposits, withdraws, number_quota_holders
            )
            push!(out, d)

        end

        return(out)
    end

    function _get_url_monthly_zip(ym::YearMonths.YearMonth)::String
        str_year = "$(YearMonths.year(ym))"
        str_month = lpad("$(YearMonths.month(ym))", 2, "0")
        url = "http://dados.cvm.gov.br/dados/FI/DOC/INF_DIARIO/DADOS/inf_diario_fi_$str_year$str_month.zip"
        return url
    end

    function _get_url_yearly_zip(ym::YearMonths.YearMonth)::String
        str_year = "$(YearMonths.year(ym))"
        url = "http://dados.cvm.gov.br/dados/FI/DOC/INF_DIARIO/DADOS/HIST/inf_diario_fi_$str_year.zip"
        return url
    end

    function _get_file_name(ym::YearMonths.YearMonth)
        str_year = "$(YearMonths.year(ym))"
        str_month = lpad("$(YearMonths.month(ym))", 2, "0")
        return "inf_diario_fi_$str_year$str_month.csv"
    end

    function _get_data(ym::YearMonths.YearMonth)
        # url = _get_url(ym)
        # r = HTTP.get(url, status_exception = false)
        # if r.status == 200
        #     return split(String(r.body), "\r\n")
        # elseif r.status == 404
        #     throw(ErrorException("CVM fund data not found for $ym"))
        # else
        #     error("error retrieving CVM fund data: $r")
        # end

        localfile = "$(tempname()).zip"
        
        try
            url = _get_url_monthly_zip(ym)
            Downloads.download(url, localfile)
        catch e
            url = _get_url_yearly_zip(ym)
            Downloads.download(url, localfile)
        end
        @assert isfile(localfile)

        fname = _get_file_name(ym)
        zip = ZipFile.Reader(localfile)

        for f in zip.files
            if f.name == fname
                ret = CSV.File(f, decimal='.', delim=';')
                close(zip)
                rm(localfile)
                return ret
            end
        end

        close(zip)
        rm(localfile)
        error("$fname not found in $url")
        
    end

end
