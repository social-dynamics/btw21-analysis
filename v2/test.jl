using Negotiations
using SQLite
using Chain
using DataFrames
using CSV

db = SQLite.DB("db.sqlite")

parliament = @chain begin
    DBInterface.execute(db, "
        select party_shorthand, seats
        from parliament
        where batchname = \"continuous_homophily\";
    ")
    DataFrame(_)
end

parliament[!, :weight] = parliament.seats ./ sum(parliament.seats)

opinion = @chain begin
    DBInterface.execute(db, "
        select o.party_id, p.party_shorthand, statement_id, position
        from opinion o
        join party p
        on o.party_id = p.party_id;
    ")
    DataFrame(_)
end

df = innerjoin(opinion, parliament, on = :party_shorthand)

select!(df, [:statement_id, :position, :weight])

CSV.write("weighted_opinions.csv", df)


