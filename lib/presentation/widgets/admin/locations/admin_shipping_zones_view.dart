import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:virtual_catalog_app/domain/entities/ubigeo.dart';
import 'package:virtual_catalog_app/presentation/providers/ubigeo_provider.dart';
import 'package:virtual_catalog_app/presentation/providers/shipping_zone_provider.dart';
import 'package:virtual_catalog_app/presentation/utils/admin_theme.dart';

class AdminShippingZonesView extends StatefulWidget {
  final String businessSlug;
  const AdminShippingZonesView({super.key, required this.businessSlug});

  @override
  State<AdminShippingZonesView> createState() => _AdminShippingZonesViewState();
}

class _AdminShippingZonesViewState extends State<AdminShippingZonesView> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  int _currentPage = 0;
  static const int _pageSize = 8;

  final Set<String> _expandedDepartamentos = {};
  final Set<String> _expandedProvincias = {};

  final Map<String, ZoneInfo> _zoneInfoMap = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UbigeoProvider>().loadDepartamentos();
      context.read<ShippingZoneProvider>().loadZones(widget.businessSlug);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ubigeoProvider = context.watch<UbigeoProvider>();
    final zoneProvider = context.watch<ShippingZoneProvider>();

    final departamentos = _filterDepartamentos(ubigeoProvider.departamentos);
    final totalPages = (departamentos.length / _pageSize).ceil();
    final pagedDepartamentos = departamentos
        .skip(_currentPage * _pageSize)
        .take(_pageSize)
        .toList();

    return Scaffold(
      backgroundColor: AdminTheme.surface,
      appBar: AppBar(
        backgroundColor: AdminTheme.cardBg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AdminTheme.border, height: 1.0),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Zonas de Entrega", style: AdminTheme.heading2()),
            Text(
              "Selecciona los distritos donde realizas envíos.",
              style: AdminTheme.bodySmall(),
            ),
          ],
        ),
        actions: [
          if (zoneProvider.isSaving)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AdminTheme.accent,
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: ElevatedButton.icon(
                onPressed: () => _saveZones(zoneProvider),
                icon: const Icon(Icons.save_outlined, size: 18),
                label: const Text("Guardar"),
                style: AdminTheme.primaryButton(),
              ),
            ),
        ],
      ),
      body: ubigeoProvider.isLoading || zoneProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AdminTheme.accent),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < AdminTheme.breakpointMobile;
                final padding = isMobile ? 12.0 : 24.0;

                return Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(padding),
                      child: Column(
                        children: [
                          TextField(
                            controller: _searchCtrl,
                            decoration: AdminTheme.inputDecoration(
                              hintText: "Buscar departamento, provincia o distrito...",
                              prefixIcon: const Icon(Icons.search, color: AdminTheme.textMuted, size: 20),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, size: 18),
                                      onPressed: () {
                                        _searchCtrl.clear();
                                        setState(() {
                                          _searchQuery = '';
                                          _currentPage = 0;
                                        });
                                      },
                                    )
                                  : null,
                            ),
                            style: AdminTheme.body(),
                            onChanged: (val) {
                              setState(() {
                                _searchQuery = val.toLowerCase();
                                _currentPage = 0;
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildSelectAllRow(zoneProvider, ubigeoProvider),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: padding),
                        itemCount: pagedDepartamentos.length,
                        itemBuilder: (context, index) {
                          return _DepartamentoTile(
                            departamento: pagedDepartamentos[index],
                            isExpanded: _expandedDepartamentos.contains(pagedDepartamentos[index].idUbigeo),
                            onToggleExpand: () => _toggleDepartamento(pagedDepartamentos[index].idUbigeo),
                            expandedProvincias: _expandedProvincias,
                            onToggleProvinciaExpand: _toggleProvincia,
                            ubigeoProvider: ubigeoProvider,
                            zoneProvider: zoneProvider,
                            searchQuery: _searchQuery,
                            zoneInfoMap: _zoneInfoMap,
                          );
                        },
                      ),
                    ),
                    if (totalPages > 1)
                      _buildPagination(totalPages, isMobile),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildSelectAllRow(ShippingZoneProvider zoneProvider, UbigeoProvider ubigeoProvider) {
    final totalSelected = zoneProvider.selectedUbigeoCodes.length;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AdminTheme.cardBg,
        borderRadius: BorderRadius.circular(AdminTheme.radiusMd),
        border: Border.all(color: AdminTheme.border, width: 0.5),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: Checkbox(
              value: totalSelected > 0,
              tristate: true,
              activeColor: AdminTheme.accent,
              checkColor: Colors.white,
              side: const BorderSide(color: AdminTheme.textMuted),
              onChanged: (val) async {
                if (totalSelected > 0) {
                  zoneProvider.deselectAll();
                } else {
                  await _selectAllDistritos(ubigeoProvider, zoneProvider);
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              totalSelected > 0
                  ? "$totalSelected distritos seleccionados"
                  : "Seleccionar todos",
              style: AdminTheme.body(),
            ),
          ),
          if (totalSelected > 0)
            TextButton(
              onPressed: () => zoneProvider.deselectAll(),
              child: Text(
                "Limpiar",
                style: AdminTheme.bodySmall().copyWith(color: AdminTheme.accent),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _selectAllDistritos(UbigeoProvider ubigeoProvider, ShippingZoneProvider zoneProvider) async {
    for (final depto in ubigeoProvider.departamentos) {
      final provincias = await ubigeoProvider.loadProvincias(depto.idUbigeo);
      for (final prov in provincias) {
        final distritos = await ubigeoProvider.loadDistritos(prov.idUbigeo);
        final codes = <String>[];
        for (final dist in distritos) {
          final code = '${depto.codigo}${prov.codigo}${dist.codigo}';
          codes.add(code);
          _zoneInfoMap[code] = ZoneInfo(
            departamento: depto.nombre,
            provincia: prov.nombre,
            distrito: dist.nombre,
          );
        }
        zoneProvider.selectMultiple(codes);
      }
    }
  }

  List<Ubigeo> _filterDepartamentos(List<Ubigeo> departamentos) {
    if (_searchQuery.isEmpty) return departamentos;
    return departamentos.where((d) {
      return d.nombre.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  void _toggleDepartamento(String id) {
    setState(() {
      if (_expandedDepartamentos.contains(id)) {
        _expandedDepartamentos.remove(id);
      } else {
        _expandedDepartamentos.add(id);
      }
    });
  }

  void _toggleProvincia(String id) {
    setState(() {
      if (_expandedProvincias.contains(id)) {
        _expandedProvincias.remove(id);
      } else {
        _expandedProvincias.add(id);
      }
    });
  }

  Widget _buildPagination(int totalPages, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 24,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AdminTheme.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: _currentPage > 0
                ? () => setState(() => _currentPage--)
                : null,
            icon: const Icon(Icons.chevron_left),
            color: AdminTheme.textSecondary,
            disabledColor: AdminTheme.textMuted.withValues(alpha: 0.3),
          ),
          const SizedBox(width: 8),
          Text(
            "Página ${_currentPage + 1} de $totalPages",
            style: AdminTheme.bodySmall(),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _currentPage < totalPages - 1
                ? () => setState(() => _currentPage++)
                : null,
            icon: const Icon(Icons.chevron_right),
            color: AdminTheme.textSecondary,
            disabledColor: AdminTheme.textMuted.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }

  Future<void> _saveZones(ShippingZoneProvider zoneProvider) async {
    try {
      await zoneProvider.saveZones(
        businessId: widget.businessSlug,
        zoneInfoMap: _zoneInfoMap,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("✅ Zonas de entrega guardadas (${zoneProvider.selectedUbigeoCodes.length} distritos)"),
          backgroundColor: AdminTheme.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al guardar: $e"),
          backgroundColor: AdminTheme.danger,
        ),
      );
    }
  }
}

class _DepartamentoTile extends StatelessWidget {
  final Ubigeo departamento;
  final bool isExpanded;
  final VoidCallback onToggleExpand;
  final Set<String> expandedProvincias;
  final ValueChanged<String> onToggleProvinciaExpand;
  final UbigeoProvider ubigeoProvider;
  final ShippingZoneProvider zoneProvider;
  final String searchQuery;
  final Map<String, ZoneInfo> zoneInfoMap;

  const _DepartamentoTile({
    required this.departamento,
    required this.isExpanded,
    required this.onToggleExpand,
    required this.expandedProvincias,
    required this.onToggleProvinciaExpand,
    required this.ubigeoProvider,
    required this.zoneProvider,
    required this.searchQuery,
    required this.zoneInfoMap,
  });

  @override
  Widget build(BuildContext context) {
    final provincias = ubigeoProvider.getProvinciasFor(departamento.idUbigeo);
    final selectedCount = _countSelectedForDepartamento(provincias);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: AdminTheme.cardDecoration(elevated: false),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(AdminTheme.radiusMd),
            onTap: () async {
              await ubigeoProvider.loadProvincias(departamento.idUbigeo);
              onToggleExpand();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Icon(
                    isExpanded ? Icons.expand_more : Icons.chevron_right,
                    color: AdminTheme.textSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.map_outlined, color: AdminTheme.accent, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      departamento.nombre,
                      style: AdminTheme.body().copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (selectedCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AdminTheme.accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "$selectedCount",
                        style: AdminTheme.caption().copyWith(
                          color: AdminTheme.accentLight,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (isExpanded && provincias.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 8, bottom: 8),
              child: Column(
                children: provincias
                    .where((p) => searchQuery.isEmpty || p.nombre.toLowerCase().contains(searchQuery))
                    .map((provincia) => _ProvinciaTile(
                          departamento: departamento,
                          provincia: provincia,
                          isExpanded: expandedProvincias.contains(provincia.idUbigeo),
                          onToggleExpand: () => onToggleProvinciaExpand(provincia.idUbigeo),
                          ubigeoProvider: ubigeoProvider,
                          zoneProvider: zoneProvider,
                          searchQuery: searchQuery,
                          zoneInfoMap: zoneInfoMap,
                        ))
                    .toList(),
              ),
            ),
          if (isExpanded && provincias.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AdminTheme.accent,
                ),
              ),
            ),
        ],
      ),
    );
  }

  int _countSelectedForDepartamento(List<Ubigeo> provincias) {
    int count = 0;
    for (final prov in provincias) {
      final distritos = ubigeoProvider.getDistritosFor(prov.idUbigeo);
      for (final dist in distritos) {
        final code = '${departamento.codigo}${prov.codigo}${dist.codigo}';
        if (zoneProvider.isSelected(code)) count++;
      }
    }
    return count;
  }
}

class _ProvinciaTile extends StatelessWidget {
  final Ubigeo departamento;
  final Ubigeo provincia;
  final bool isExpanded;
  final VoidCallback onToggleExpand;
  final UbigeoProvider ubigeoProvider;
  final ShippingZoneProvider zoneProvider;
  final String searchQuery;
  final Map<String, ZoneInfo> zoneInfoMap;

  const _ProvinciaTile({
    required this.departamento,
    required this.provincia,
    required this.isExpanded,
    required this.onToggleExpand,
    required this.ubigeoProvider,
    required this.zoneProvider,
    required this.searchQuery,
    required this.zoneInfoMap,
  });

  @override
  Widget build(BuildContext context) {
    final distritos = ubigeoProvider.getDistritosFor(provincia.idUbigeo);
    final distritoCodes = distritos
        .map((d) => '${departamento.codigo}${provincia.codigo}${d.codigo}')
        .toList();
    final selectedCount = zoneProvider.countSelectedIn(distritoCodes);
    final allSelected = distritos.isNotEmpty && selectedCount == distritos.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: AdminTheme.surface,
        borderRadius: BorderRadius.circular(AdminTheme.radiusSm),
        border: Border.all(color: AdminTheme.border, width: 0.3),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(AdminTheme.radiusSm),
            onTap: () async {
              await ubigeoProvider.loadDistritos(provincia.idUbigeo);
              final loadedDistritos = ubigeoProvider.getDistritosFor(provincia.idUbigeo);
              for (final dist in loadedDistritos) {
                final code = '${departamento.codigo}${provincia.codigo}${dist.codigo}';
                zoneInfoMap[code] = ZoneInfo(
                  departamento: departamento.nombre,
                  provincia: provincia.nombre,
                  distrito: dist.nombre,
                );
              }
              onToggleExpand();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    isExpanded ? Icons.expand_more : Icons.chevron_right,
                    color: AdminTheme.textMuted,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      provincia.nombre,
                      style: AdminTheme.body().copyWith(fontSize: 13),
                    ),
                  ),
                  if (selectedCount > 0)
                    Text(
                      "$selectedCount/${distritos.isEmpty ? '?' : distritos.length}",
                      style: AdminTheme.caption().copyWith(
                        color: AdminTheme.accentLight,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  const SizedBox(width: 4),
                  if (distritos.isNotEmpty)
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: Checkbox(
                        value: allSelected
                            ? true
                            : selectedCount > 0
                                ? null
                                : false,
                        tristate: true,
                        activeColor: AdminTheme.accent,
                        checkColor: Colors.white,
                        side: const BorderSide(color: AdminTheme.textMuted),
                        onChanged: (val) {
                          if (allSelected) {
                            zoneProvider.deselectMultiple(distritoCodes);
                          } else {
                            for (final dist in distritos) {
                              final code = '${departamento.codigo}${provincia.codigo}${dist.codigo}';
                              zoneInfoMap[code] = ZoneInfo(
                                departamento: departamento.nombre,
                                provincia: provincia.nombre,
                                distrito: dist.nombre,
                              );
                            }
                            zoneProvider.selectMultiple(distritoCodes);
                          }
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (isExpanded && distritos.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 24, right: 8, bottom: 8),
              child: Column(
                children: distritos
                    .where((d) => searchQuery.isEmpty || d.nombre.toLowerCase().contains(searchQuery))
                    .map((distrito) {
                  final code = '${departamento.codigo}${provincia.codigo}${distrito.codigo}';
                  final isChecked = zoneProvider.isSelected(code);
                  return InkWell(
                    borderRadius: BorderRadius.circular(4),
                    onTap: () {
                      zoneInfoMap[code] = ZoneInfo(
                        departamento: departamento.nombre,
                        provincia: provincia.nombre,
                        distrito: distrito.nombre,
                      );
                      zoneProvider.toggleZone(
                        ubigeoCode: code,
                        departamento: departamento.nombre,
                        provincia: provincia.nombre,
                        distrito: distrito.nombre,
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 40,
                            height: 36,
                            child: Checkbox(
                              value: isChecked,
                              activeColor: AdminTheme.accent,
                              checkColor: Colors.white,
                              side: const BorderSide(color: AdminTheme.textMuted),
                              onChanged: (val) {
                                zoneInfoMap[code] = ZoneInfo(
                                  departamento: departamento.nombre,
                                  provincia: provincia.nombre,
                                  distrito: distrito.nombre,
                                );
                                zoneProvider.toggleZone(
                                  ubigeoCode: code,
                                  departamento: departamento.nombre,
                                  provincia: provincia.nombre,
                                  distrito: distrito.nombre,
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              distrito.nombre,
                              style: AdminTheme.body().copyWith(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          if (isExpanded && distritos.isEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AdminTheme.accent,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
